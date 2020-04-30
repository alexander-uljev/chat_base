defmodule Chat.Base.UtilsTest do

  use ExUnit.Case
  alias Chat.Base.{Utils, User}
  import Ecto.Changeset

  setup_all :create_context


  test "accepts a valid login and password",
  %{valid_login: login, valid_password: password} do
    changeset = create_changeset(login, password)
    assert Utils.validate_login(changeset).valid?
  end

  test "denies a login including illegal characters",
  %{invalid_login: login, valid_password: password} do
    changeset = create_changeset(login, password)
    assert \
      [{:login, {"illegal characters present", []}}]
      == Utils.validate_login(changeset).errors
  end

  test "denies a login shorter than 3 characters",
  %{short_login: login, valid_password: password} do
    changeset = create_changeset(login, password)
    assert \
      [{:login, {"should be at least %{count} character(s)",
      [{:count, 3}, {:validation, :length}, {:kind, :min}, {:type, :string}]}}]
      == Utils.validate_login(changeset).errors
  end

  test "denies a password with no digits",
  %{valid_login: login, no_digits_password: password} do
    changeset = create_changeset(login, password)
    assert \
      [{:password, {"no digits present", []}}]
      == Utils.validate_password(changeset).errors
  end

  test "denies a password with no capital letters",
  %{valid_login: login, no_capital_letter_password: password} do
    changeset = create_changeset(login, password)
    assert \
      [{:password, {"no capital letters present", []}}]
      == Utils.validate_password(changeset).errors
  end

  test "denies a password with illegal characters",
  %{valid_login: login, illegal_characters_password: password} do
    changeset = create_changeset(login, password)
    assert \
      [{:password, {"illegal characters present", []}}]
      == Utils.validate_password(changeset).errors
  end

  test "denies a password with no special characters",
  %{valid_login: login, no_special_characters_password: password} do
    changeset = create_changeset(login, password)
    assert \
      [{:password, {"no special characters present", []}}]
      == Utils.validate_password(changeset).errors
  end

  test "denies a password with less than 8 characters",
  %{valid_login: login, short_password: password} do
    changeset = create_changeset(login, password)
    assert \
      [{:password, {"should be at least %{count} character(s)",
        [{:count, 8},   {:validation, :length},
         {:kind, :min}, {:type, :string}]}}]
      == Utils.validate_password(changeset).errors
  end

  test "returns multiple validation errors",
  %{invalid_login: login, no_special_characters_password: password} do
    changeset =
      create_changeset(login, password)
      |> Utils.validate_password()
      |> Utils.validate_login()
    assert changeset.errors ==
      [{:login,    {"illegal characters present",    []}},
       {:password, {"no special characters present", []}}]
  end

  test "returns multiple validation errors for single field",
  %{valid_login: login, very_wrong_password: password} do
    changeset =
      create_changeset(login, password)
      |> Utils.validate_password()
    assert changeset.errors == Enum.reverse([
      {:password, {"no digits present", []}},
      {:password, {"no capital letters present", []}},
      {:password, {"illegal characters present", []}},
      {:password, {"no special characters present", []}},
      {:password, {"should be at least %{count} character(s)",
        [{:count, 8}, {:validation, :length},
         {:kind, :min}, {:type, :string}]}}])
  end



  defp create_context(_) do
    %{
      valid_login: "Alexander",
      invalid_login: "F4ck!t@ll",
      short_login: "Al",
      valid_password: "F4ck!t@ll",
      short_password: "4LL_gd",
      very_wrong_password: "to.izy",
      no_digits_password: "HowsEve?",
      no_capital_letter_password: "all!r8m8",
      illegal_characters_password: "alL!r.m8",
      no_special_characters_password: "t00easYy"
    }
  end

  defp create_changeset(login, password) do
    cast(%User{}, %{login: login, password: password}, [:login, :password])
  end

end
