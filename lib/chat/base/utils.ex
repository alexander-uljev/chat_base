defmodule Chat.Base.Utils do
  import Ecto.Changeset

  @moduledoc """
  Utilities module to validate user input in one line.
  Legal characters are: ! $ % * - / ? \ _ = +
  Illegal characters are: . , ; : ' " @ % ^ ( ) < > [ ] { }
  Minimal password length: 8
  Minimal login length: 3
  Furthermore password must include at least one capital letter, a digit and a
  legal special character.
  """

  @doc """
  A pipeline of change validators to ensure that password is not too easy, too
  short or includes illegal characters but includes legal special characters.

  For list of valid characters please refer to module documentation.
  """
  @spec validate_password(Ecto.Changeset.t()) :: Ecto.Changeset.t()

  def validate_password(changeset) do
    changeset
    |> validate_change(:password, &digits_present/2)
    |> validate_change(:password, &capital_letters_present/2)
    |> validate_change(:password, &illegal_characters_abscent/2)
    |> validate_change(:password, &special_characters_present/2)
    |> validate_length(:password, min: 8)
  end

  @doc """
  A pipeline to validate that login is not too short and does not include
  illegal characters.
  """
  @spec validate_login(Ecto.Changeset.t()) :: Ecto.Changeset.t()

  def validate_login(changeset) do
    changeset
    |> validate_change(:login, &illegal_characters_abscent/2)
    |> validate_length(:login, min: 3)
  end

  @spec digits_present(atom(), String.t()) :: list()
  defp digits_present(key, val) do
    if Regex.match?(~r/\d/, val),
    do: [], else: [{key, "no digits present"}]
  end

  @spec capital_letters_present(atom(), String.t()) :: list()
  defp capital_letters_present(key,val) do
    if Regex.match?(~r/[A-Z]/, val),
    do: [], else: [{key, "no capital letters present"}]
  end

  @spec illegal_characters_abscent(atom(), String.t()) :: list()
  defp illegal_characters_abscent(key, val) do
    if Regex.match?(~r/[.,;:'"@%^()<>{}\[\]]/, val),
    do: [{key, "illegal characters present"}], else: []
  end

  @spec special_characters_present(atom(), String.t()) :: list()
  defp special_characters_present(key, val) do
    if Regex.match?(~r/[!$%*\-\/?\\_=+]/, val),
    do: [], else: [{key, "no special characters present"}]
  end

end
