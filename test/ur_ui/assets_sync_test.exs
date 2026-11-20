defmodule UrUi.AssetsSyncTest do
  use ExUnit.Case, async: true

  @moduledoc """
  `assets/ur_ui.css` is the source of truth for shadcn/ui's default neutral
  theme. `priv/static/ur_ui.css` is a mirror used by phoenix_storybook.
  """

  @canonical Path.expand("../../assets/ur_ui.css", __DIR__)
  @mirror Path.expand("../../priv/static/ur_ui.css", __DIR__)

  @theme_values %{
    "background" => {"oklch(1 0 0)", "oklch(0.145 0 0)"},
    "foreground" => {"oklch(0.145 0 0)", "oklch(0.985 0 0)"},
    "card" => {"oklch(1 0 0)", "oklch(0.205 0 0)"},
    "card-foreground" => {"oklch(0.145 0 0)", "oklch(0.985 0 0)"},
    "popover" => {"oklch(1 0 0)", "oklch(0.205 0 0)"},
    "popover-foreground" => {"oklch(0.145 0 0)", "oklch(0.985 0 0)"},
    "primary" => {"oklch(0.205 0 0)", "oklch(0.922 0 0)"},
    "primary-foreground" => {"oklch(0.985 0 0)", "oklch(0.205 0 0)"},
    "secondary" => {"oklch(0.97 0 0)", "oklch(0.269 0 0)"},
    "secondary-foreground" => {"oklch(0.205 0 0)", "oklch(0.985 0 0)"},
    "muted" => {"oklch(0.97 0 0)", "oklch(0.269 0 0)"},
    "muted-foreground" => {"oklch(0.556 0 0)", "oklch(0.708 0 0)"},
    "accent" => {"oklch(0.97 0 0)", "oklch(0.269 0 0)"},
    "accent-foreground" => {"oklch(0.205 0 0)", "oklch(0.985 0 0)"},
    "destructive" => {"oklch(0.577 0.245 27.325)", "oklch(0.704 0.191 22.216)"},
    "border" => {"oklch(0.922 0 0)", "oklch(1 0 0 / 10%)"},
    "input" => {"oklch(0.922 0 0)", "oklch(1 0 0 / 15%)"},
    "ring" => {"oklch(0.708 0 0)", "oklch(0.556 0 0)"},
    "chart-1" => {"oklch(0.87 0 0)", "oklch(0.87 0 0)"},
    "chart-2" => {"oklch(0.556 0 0)", "oklch(0.556 0 0)"},
    "chart-3" => {"oklch(0.439 0 0)", "oklch(0.439 0 0)"},
    "chart-4" => {"oklch(0.371 0 0)", "oklch(0.371 0 0)"},
    "chart-5" => {"oklch(0.269 0 0)", "oklch(0.269 0 0)"},
    "sidebar" => {"oklch(0.985 0 0)", "oklch(0.205 0 0)"},
    "sidebar-foreground" => {"oklch(0.145 0 0)", "oklch(0.985 0 0)"},
    "sidebar-primary" => {"oklch(0.205 0 0)", "oklch(0.488 0.243 264.376)"},
    "sidebar-primary-foreground" => {"oklch(0.985 0 0)", "oklch(0.985 0 0)"},
    "sidebar-accent" => {"oklch(0.97 0 0)", "oklch(0.269 0 0)"},
    "sidebar-accent-foreground" => {"oklch(0.205 0 0)", "oklch(0.985 0 0)"},
    "sidebar-border" => {"oklch(0.922 0 0)", "oklch(1 0 0 / 10%)"},
    "sidebar-ring" => {"oklch(0.708 0 0)", "oklch(0.556 0 0)"},
    "radius" => {"0.625rem", "0.625rem"}
  }

  test "priv/static/ur_ui.css mirrors assets/ur_ui.css exactly" do
    assert File.read!(@canonical) == File.read!(@mirror),
           "priv/static/ur_ui.css has drifted from assets/ur_ui.css — re-copy the mirror"
  end

  test "every shadcn neutral variable has the registry value in light and dark modes" do
    css = File.read!(@canonical)

    for {selector, mode} <- [{":root", 0}, {".dark", 1}],
        {name, values} <- @theme_values do
      block = css_block(css, selector)
      value = elem(values, mode)

      assert block =~ "--#{name}: #{value};",
             "expected #{selector} to define --#{name}: #{value}"
    end
  end

  test "legacy UR Wife tokens and styling bans are gone" do
    css = File.read!(@canonical)

    refute css =~ "--ur-wifes-"
    refute css =~ "UR black"
    refute css =~ "Focus states use outline only"
    refute css =~ "shadow and filter properties"
  end

  defp css_block(css, selector) do
    pattern = Regex.compile!("(?:^|\\n)" <> Regex.escape(selector) <> "\\s*\\{([^}]*)\\}")
    [_, block] = Regex.run(pattern, css)
    block
  end
end
