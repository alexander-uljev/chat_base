defmodule Chat.Base.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Chat.Base.Repo
    ]
    opts = [strategy: :one_for_one, name: Chat.Base.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
