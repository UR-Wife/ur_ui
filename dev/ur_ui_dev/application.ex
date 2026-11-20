defmodule UrUiDev.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: UrUiDev.PubSub},
      UrUiDev.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: UrUiDev.Supervisor)
  end
end