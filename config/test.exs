use Mix.Config

# Configure your database
config :chat_base, Chat.Base.Repo,
  username: "postgres",
  password: "postgres",
  database: "chat_base_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  show_sensitive_data_on_connection_error: true
