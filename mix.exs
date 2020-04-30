defmodule Chat.Base.MixProject do
  use Mix.Project

  def project do
    [
      app: :chat_base,
      version: "0.1.0",
      elixir: "~> 1.10",
#     config_path: "../../config/config.exs",
      build_path: "../../_build",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Chat.Base.Application, []}
    ]
  end

  def aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.3.3"},
      {:postgrex, "~> 0.15.0"}
    ]
  end
end
