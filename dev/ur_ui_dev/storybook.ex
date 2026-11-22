defmodule UrUiDev.Storybook do
  @moduledoc false
  use PhoenixStorybook,
    otp_app: :ur_ui,
    content_path: Path.expand("../../storybook", __DIR__),
    # remote paths, served by UrUiDev.Endpoint
    css_path: "/ur_ui.css",
    js_path: "/storybook.js"
end
