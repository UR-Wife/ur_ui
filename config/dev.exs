import Config

config :ur_ui, UrUiDev.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: false,
  debug_errors: true,
  secret_key_base: "iou1nzaM3j4MzPcwJxCa4SLvKyRhb++ffcuvXNYJxIUpUFx89XR0JEyTKGN6u06t",
  live_view: [signing_salt: "urUiDevLV"],
  pubsub_server: UrUiDev.PubSub,
  render_errors: [formats: [html: Phoenix.Endpoint.RenderErrors], layout: false],
  server: true

config :logger, level: :info

# Bundles dev/assets/storybook.js (ur_ui's colocated hooks) for Storybook.
# Paths follow Mix.Project.build_path() so a custom MIX_BUILD_PATH works.
config :esbuild,
  version: "0.25.0",
  ur_ui_dev: [
    args:
      ~w(dev/assets/storybook.js --bundle --format=iife) ++
        ["--outfile=#{Path.join([Mix.Project.build_path(), "storybook", "storybook.js"])}"],
    cd: Path.expand("..", __DIR__),
    env: %{"NODE_PATH" => Mix.Project.build_path()}
  ]
