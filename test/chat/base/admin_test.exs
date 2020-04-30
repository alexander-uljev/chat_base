defmodule Chat.Base.AdminTest do
  use ExUnit.Case
  alias Chat.Base.Admin

  setup_all :create_context

################################################################################
################################################################################

  test "creates changeset with valid password",
  %{valid_attrs: attrs, admin: admin} do
    assert Admin.changeset(admin, attrs).valid?
  end

  test "fails to create changeset with invalid password",
  %{invalid_password_attrs: attrs, admin: admin} do
    refute Admin.changeset(admin, attrs).valid?
  end

  test "creates changeset with valid login",
  %{valid_attrs: attrs, admin: admin}do
    assert Admin.changeset(admin, attrs).valid?
  end

  test "fails to create changeset with invalid login",
  %{invalid_login_attrs: attrs, admin: admin} do
    refute Admin.changeset(admin, attrs).valid?
  end

################################################################################
################################################################################

  defp create_context(_) do
    %{
      valid_attrs:            %{login: "good_guy", password: "6ecYure!"},
      invalid_login_attrs:    %{login: "<bad>_guy", password: "6ecYure!"},
      invalid_password_attrs: %{login: "good_guy", password: "too_easy"},
      admin: %Admin{}
    }
  end
end
