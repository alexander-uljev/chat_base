defmodule Chat.Base.Spectrator do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chat.Base.Utils

  schema "spectrators" do
    field :login, :string
    field :password, :string

    timestamps()
  end

  @doc false
  def changeset(spectrator, attrs) do
    spectrator
    |> cast(attrs, [:login, :password])
    |> validate_required([:login, :password])
    |> Utils.validate_password()
    |> Utils.validate_login()
  end

end
