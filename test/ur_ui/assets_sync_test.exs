defmodule UrUi.AssetsSyncTest do
  use ExUnit.Case, async: true

  @moduledoc """
  `assets/ur_ui.css` is the single source of truth for the design tokens
  (per spec). `priv/static/ur_ui.css` is a mirror that lets phoenix_storybook
  resolve and cache-bust `css_path`. These guards prove the two cannot drift
  and that hardcoded colors stay confined to the `:root` token block.
  """

  @canonical Path.expand("../../assets/ur_ui.css", __DIR__)
  @mirror Path.expand("../../priv/static/ur_ui.css", __DIR__)

  test "priv/static/ur_ui.css mirrors assets/ur_ui.css exactly" do
    assert File.read!(@canonical) == File.read!(@mirror),
           "priv/static/ur_ui.css has drifted from assets/ur_ui.css — re-copy the mirror"
  end

  test "hardcoded colors exist only inside the :root token block" do
    css = File.read!(@canonical)

    [_prefix, rest] = String.split(css, ":root {", parts: 2)
    [_tokens, suffix] = String.split(rest, "}", parts: 2)

    refute suffix =~ ~r/#[0-9a-fA-F]{3,8}\b/,
           "hardcoded color outside the :root token block in assets/ur_ui.css"

    for forbidden <- ["style=", "box-shadow", "text-shadow", "filter:", "backdrop-filter"] do
      refute suffix =~ forbidden,
             "#{forbidden} is forbidden outside the token block in assets/ur_ui.css"
    end
  end

  test "the :root block defines the --ur-wifes-* palette tokens" do
    css = File.read!(@canonical)

    [_prefix, rest] = String.split(css, ":root {", parts: 2)
    [tokens, _suffix] = String.split(rest, "}", parts: 2)

    for token <- ~w(--ur-wifes-black --ur-wifes-red --ur-wifes-white --ur-wifes-primary) do
      assert tokens =~ "#{token}:", "missing design token #{token} in assets/ur_ui.css"
    end

    assert length(String.split(tokens, "--ur-wifes-")) >= 15,
           "expected at least 14 --ur-wifes-* tokens in the :root block"
  end

  test "semantic tokens implement the UR black background and white foreground" do
    css = File.read!(@canonical)
    [_prefix, rest] = String.split(css, ":root {", parts: 2)
    [tokens, _suffix] = String.split(rest, "}", parts: 2)

    assert tokens =~ "--ur-wifes-bg: var(--ur-wifes-black);"
    assert tokens =~ "--ur-wifes-fg: var(--ur-wifes-white);"
    assert tokens =~ "--ur-wifes-primary: var(--ur-wifes-red);"
  end
end
