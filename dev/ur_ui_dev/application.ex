defmodule UrUiDev.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    # Colocated hooks are extracted at compile time; bundle them before
    # Storybook serves its first page.
    0 = Esbuild.install_and_run(:ur_ui_dev, [])

    children = [
      {Phoenix.PubSub, name: UrUiDev.PubSub},
      UrUiDev.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: UrUiDev.Supervisor)
  end
end
