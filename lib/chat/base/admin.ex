defmodule Chat.Base.Admin do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chat.Base.Utils

  schema "admins" do
    field :login, :string
    field :password, :string

    timestamps()
  end

  @doc false
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, [:login, :password])
    |> validate_required([:login, :password])
    |> Utils.validate_password()
    |> Utils.validate_login()
  end
end
