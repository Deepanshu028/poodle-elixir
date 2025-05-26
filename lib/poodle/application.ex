defmodule Poodle.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # HTTP client pool
      {Finch, name: Poodle.Finch, pools: %{default: [size: 10, count: 1]}}
    ]

    opts = [strategy: :one_for_one, name: Poodle.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
