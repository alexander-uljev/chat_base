# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Chat.Repo.insert!(%Chat.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule Chat.Base.Repo.InitialData do
  alias Chat.Base.Repo

  defp populate_changeset(member, login) do
    apply(member, :changeset, [struct(member),
      %{login: login, password: "A4ter!D4sk"}])
  end

  def generate_members(type, amount, list \\ []) # when is_integer(amount)

  def generate_members(_type, 0, list) do
    list
  end

  def generate_members(type, amount, list) do
    generate_members(type, amount - 1,
      [populate_changeset(type, "member#{floor(:random.uniform() * 1000)}") | list])
  end

  def insert_members(list) do
    Enum.each(list, fn (member) -> Repo.insert!(member) end)
  end

end

alias Chat.Base.{Repo, User, Admin, Spectrator}

Enum.each([User, Admin, Spectrator], fn (type) ->
  Repo.InitialData.insert_members(
    Repo.InitialData.generate_members(type, 5)
  )
end)
