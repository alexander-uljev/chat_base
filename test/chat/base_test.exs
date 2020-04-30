defmodule Chat.BaseTest do
  use ExUnit.Case
  alias Chat.Base.{User, Admin, Spectrator, Repo}
  @members [User, Admin, Spectrator]

  setup_all :cleanup
  setup :form_attrs

  test "creates a user/admin/spectrator", %{attrs: attrs} do
    Enum.each(@members, fn(member) ->
      {:ok, %struct{} = r_member} = Chat.Base.create(member, attrs)
      assert r_member.login == attrs.login
      assert struct == member
    end)
  end

  test "fails to create a user/admin/spectrator and returns a friendly message",
  %{attrs: attrs} do
    {:error, :inval_attrs, {_struct, errors}} = Chat.Base.create(User,
      %{attrs | password: "too_easy"})
    assert "no digits present" in errors.password
  end

  test "reads a user/admin/spectrator", %{attrs: attrs} do
    Enum.each(@members, fn(member) ->
      {:ok, %struct{} = r_member} = Chat.Base.create(member, attrs)
      {:ok, r_member} = Chat.Base.read(member, attrs)
      assert r_member.login == attrs.login
      assert struct == member
    end)
  end

  test "updates a user/admin/spectrator", %{attrs: attrs} do
    Enum.each(@members, fn(member) ->
      {:ok, _schema} = Chat.Base.create(member, attrs)
      upd_attrs = %{attrs | login: random_login()}
      IO.inspect attrs
      {:ok, n_member} = Chat.Base.update(member, attrs, upd_attrs)
      assert n_member.login == upd_attrs.login
    end)
  end

  test "deletes a user/admin/spectrator", %{attrs: attrs} do
    Enum.each(@members, fn(member) ->
      {:ok, _schema} = Chat.Base.create(member, attrs)
      {:ok, d_member} = Chat.Base.delete(member, attrs)
      assert Ecto.get_meta(d_member, :state) == :deleted
    end)
  end

  test "authenticates a user/admin/spectrator", %{attrs: attrs} do
    Enum.each(@members, fn(member) ->
      {:ok, _schema} = Chat.Base.create(member, attrs)
      {:ok, r_member} = Chat.Base.authenticate(member, attrs, [:login])
      assert r_member.login
      refute Map.get(r_member, :password, nil)
    end)
  end

  test "checks if a user/admin/spectrator is a registerd member",
  %{attrs: attrs} do
    Enum.each(@members, fn(member) ->
      {:ok, _schema} = Chat.Base.create(member, attrs)
      assert Chat.Base.member?(member, attrs)
      attrs = %{attrs | login: "doctor_who"}
      refute Chat.Base.member?(member, attrs)
    end)
  end

  test "checks if a name is already registered in the system",
  %{attrs: attrs} do
    Enum.each(@members, fn(member) ->
      {:ok, _schema} = Chat.Base.create(member, attrs)
      refute Chat.Base.login_available?(member, attrs)
      attrs = %{attrs | login: random_login() <> "777"}
      assert Chat.Base.login_available?(member, attrs)
    end)
  end

  defp form_attrs(_context) do
    %{attrs: %{login: random_login(), password: "6eqYure!"}}
  end

  defp cleanup(_) do
    on_exit(fn() ->
      for member <- @members, do: Repo.delete_all(member)
    end)
  end

  defp random_login() do
    "member#{
      floor(Enum.random(0..1000000))}"
  end

end
