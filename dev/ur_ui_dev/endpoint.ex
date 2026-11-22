defmodule UrUiDev.Endpoint do
  @moduledoc false
  use Phoenix.Endpoint, otp_app: :ur_ui

  @session_options [
    store: :cookie,
    key: "_ur_ui_dev",
    signing_salt: "urUiDevS",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  plug Plug.Static,
    at: "/",
    from: Path.expand("../../assets", __DIR__),
    only: ~w(ur_ui.css)

  # The avatar demo image, shared with the e2e reference app so both sides
  # load the same bytes.
  plug Plug.Static,
    at: "/",
    from: Path.expand("../../e2e/reference/public", __DIR__),
    only: ~w(ur_ui_logo.svg)

  # Dev-only bundle of ur_ui's LiveView hooks, built by UrUiDev.Application.
  plug Plug.Static,
    at: "/",
    from: Path.join(Mix.Project.build_path(), "storybook"),
    only: ~w(storybook.js)

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug UrUiDev.Router
end