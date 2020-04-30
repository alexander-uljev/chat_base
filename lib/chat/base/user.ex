defmodule Chat.Base.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chat.Base.Utils

  schema "users" do
    field :login, :string
    field :name, :string
    field :password, :string

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:login, :password, :name])
    |> validate_required([:login, :password])
    |> Utils.validate_password()
    |> Utils.validate_login()
  end

end
