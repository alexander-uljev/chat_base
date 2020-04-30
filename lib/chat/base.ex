defmodule Chat.Base do

  @moduledoc """
  Base is responsible for registering, authenticating, searching and deleting
  Chat application members. Some other convinience functions available. Login
  and password constraints:

  - Legal characters are: ! $ % * - / ? \ _ = +
  - Illegal characters are: . , ; : ' " @ % ^ ( ) < > [ ] { }
  - Minimal password length: 8
  - Minimal login length: 3

  Furthermore password must include at least one capital letter, a digit and a
  legal special character.

  """

  require Ecto.Query
  require Logger
  alias Chat.Base.{User, Admin, Spectrator, Repo}

  @typedoc """
  Type of members supported by `Chat.Base`
  """
  @type member :: User | Admin | Spectrator
  @type member_schema :: %User{} | %Admin{} | %Spectrator{}
  @type login_pass_attrs :: %{login: String.t(), password: String.t()}
  @type invalid_attributes_error
  :: {:error, :inval_attrs, {member(), map()}}
  @type not_a_member_error
  :: {:error, :not_memb, {member(), String.t()}}

  @supported_members [User, Admin, Spectrator]

  defguardp is_id(value) when is_integer(value) and value > 0

  @doc """
  Creates a member of a given type. Requires :login and :password keys in attrs
  argument, which must satisfy safety constraints described in the module's
  documentation.
  """
  @spec create(member :: member(), attrs :: login_pass_attrs())
  :: {:ok, member_schema()} | invalid_attributes_error()

  def create(member, attrs)
  when member in @supported_members do
    changeset = apply(member, :changeset, [struct(member), attrs])
    with {:error, changeset} <- Repo.insert(changeset) do
      invalid_attributes_error(member, changeset)
    end
  end

  def create(member, _) when member in @supported_members do
    login_password_missing_error()
  end

  @doc """
  Reads a member from the database. Needs *:login* and *:password* keys in attrs
  map. Read safety section in module documentation for acceptable values.
  """
  @spec read(member :: member(), atrrs :: login_pass_attrs() | pos_integer())
  :: {:ok, member_schema()} | invalid_attributes_error()

  def read(member, %{login: _, password: _} = attrs)
  when member in @supported_members do
    Repo.get_by(member, attrs) |> form_read_response(member)
  end

  # SAFETY FIRST
  def read(member, id)
  when member in @supported_members and is_id(id) do
    Repo.get(member, id) |> form_read_response(member)
  end

  def read(member, _)when member in @supported_members do
    login_password_missing_error()
  end

  @doc """
  Updates a member record in database. Needs :login and :password keys in attrs
  map. Read safety section in module documentation for acceptable values. It
  also accepts Ecto.Schema as the member argument.
  """
  @spec update(member :: member(),
               schema :: Ecto.Schema.t(),
               attrs :: login_pass_attrs())
  :: {:ok, member_schema()} | invalid_attributes_error()

  def update(member, %{id: _, __meta__: _, __struct__: _} = schema, attrs)
  when is_map(attrs) do
    changeset = apply(member, :changeset, [schema, attrs])
    with {:error, changeset} <- Repo.update(changeset) do
      invalid_attributes_error(member, changeset)
    end
  end

  @doc """
  Updates a member record in database. Needs :login and :password keys in attrs
  map. Read safety section in module documentation for acceptable values.
  """
  @spec update(member :: member(),
               cur_attrs :: login_pass_attrs(),
               upd_attrs :: login_pass_attrs())
  :: {:ok, member_schema()} | invalid_attributes_error() | not_a_member_error()

  def update(member, %{login: _, password: _} = cur_attrs, upd_attrs)
  when member in @supported_members
  and is_map(upd_attrs) do
    case read(member, cur_attrs) do
      {:ok, map} ->
        schema = Repo.get(member, map.id)
        update(member, schema, upd_attrs)
      {:error, changeset} ->
        invalid_attributes_error(member, changeset)
    end
  end

  def update(member, _) when member in @supported_members do
    login_password_missing_error()
  end

  @doc """
  Deletes the system member from database. Requires a module name as the first
  argument and an Ecto schema or login_pass_attrs as the second. Returns :ok
  atom or invalid_attributes_error or not_a_member_error.
  """
  @spec delete(member :: member(),
               attrs :: Ecto.Schema.t() | login_pass_attrs())
  :: :ok | invalid_attributes_error() | not_a_member_error()

  def delete(member, %{id: _, __meta__: _, __struct__: _} = schema)
  when member in @supported_members do
    with {:error, changeset} <- Repo.delete(schema) do
      invalid_attributes_error(member, changeset)
    end
  end

  def delete(member, %{login: _, password: _} = attrs)
  when member in @supported_members do
    attrs = Map.take(attrs, [:login, :password])
    case read(member, attrs) do
      {:ok, map} ->
        schema = Repo.get(member, map.id)
        delete(member, schema)
      {:error, changeset} ->
        invalid_attributes_error(member, changeset)
    end
  end

  def delete(member, _)
  when member in @supported_members do
    login_password_missing_error()
  end

  @doc """
  A function for member schema shaping opportunity. Reads a member and returns
  fileds mentioned in return_fields argument.
  """
  @spec authenticate(member       :: member(),
                     atrrs        :: login_pass_attrs(),
                     return_fields :: [atom(), ...])
  :: {:ok, member_schema()} | invalid_attributes_error()

  def authenticate(member, attrs, return_fields) do
    case read(member, attrs) do
      {:error, changeset} ->
        invalid_attributes_error(member, changeset)
      {:ok, schema} ->
        schema_keys = Map.keys(schema)
        if Enum.all?(return_fields, &(&1 in schema_keys)) do
          return_fields =
            Enum.map(return_fields, fn(field) ->
              {field, Map.fetch!(schema, field)}
            end)
            |> Enum.into(%{})
          {:ok, return_fields}
        else
          {:error, :field_not_found}
        end
    end
  end

  @doc """
  Fetches member id by login name. To be deprecated.
  """
  @spec get_id_by_login(member :: member(), login :: String.t()) :: pos_integer()

  def get_id_by_login(member, login) do
    case Repo.get_by(member, login: login) do
      nil ->
        {:error, "Member #{login}, not found"}
      member ->
        {:ok, member.id}
    end
  end

  @doc """
  Checks if there is a member with given :login. Takes a member module and
  login_pass_attrs, returns boolean value.
  """
  @spec member?(member :: member(), attrs :: login_pass_attrs()) :: boolean()

  def member?(member, attrs) do
    case Repo.get_by(member, attrs) do
      %_{} -> true
      nil  -> false
    end
  end

  @doc """
  Convinience function to check if login provided is already registered on the
  system. Negates result of `member?/2` function.
  """
  @spec login_available?(member :: member(), attrs :: login_pass_attrs())
  :: boolean()

  def login_available?(member, attrs) do
    not member?(member, attrs)
  end

  ### PRIVATE ###
  @spec traverse_errors(Ecto.Changeset.t()) :: [term()]
  defp traverse_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn({msg, opts}) ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @spec login_password_missing_error() :: none()
  defp login_password_missing_error() do
    {:error, :miss_log_pass, "attrs argument must include :login and :password keys"}
  end

  @spec invalid_attributes_error(member(), Ecto.Changeset.t())
  :: {:error, :inval_attrs, {member(), list()}}
  defp invalid_attributes_error(member, changeset) do
    {:error, :inval_attrs, {member, traverse_errors(changeset)}}
  end

  @spec form_read_response(nil | Exto.Schema.t(), member()) ::
  {:error, :not_memb, {member(), String.t()}} | map()
  defp form_read_response(result, member) do
    if result == nil do
      {:error, :not_memb, {member, "member not found"}}
    else
      {:ok,
        result |> Map.take([:id, :login, :password, :name, :updated_at, :inserted_at])}
    end
  end

end
