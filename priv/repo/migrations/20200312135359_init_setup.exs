defmodule Chat.Repo.Migrations.CreateSpectrators do
  use Ecto.Migration

  def change do

    create table(:spectrators) do
      add :login, :string, null: false
      add :password, :string, null: false
      timestamps()
    end

    create table(:admins) do
      add :login, :string, null: false
      add :password, :string, null: false
      timestamps()
    end

    create table(:users) do
      add :login, :string, null: false
      add :password, :string, null: false
      add :name, :string, default: nil
      timestamps()
    end
    
    create unique_index("users", [:login])
    create unique_index("admins", [:login])
    create unique_index("spectrators", [:login])
 
  end
end
