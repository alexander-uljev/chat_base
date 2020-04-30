defmodule Chat.Base.Repo do
  use Ecto.Repo,
    otp_app: :chat_base,
    adapter: Ecto.Adapters.Postgres
end
