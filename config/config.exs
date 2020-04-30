import Config

config :chat_base, Chat.Base.Repo,
  database: "chat_base",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :chat_base,
  ecto_repos: [Chat.Base.Repo]

import_config "#{Mix.env()}.exs"
