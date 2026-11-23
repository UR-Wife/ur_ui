defmodule UrUi.ToggleGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  defp slot(value, content, disabled \\ nil) do
    %{
      __slot__: :item,
      value: value,
      disabled: disabled,
      inner_block: fn _changed, _argument -> content end
    }
  end

  defp render_toggle_group(assigns \\ %{}) do
    defaults = %{
      id: "format",
      item: [
        slot("bold", "Bold"),
        slot("italic", "Italic")
      ]
    }

    render_component(&Components.toggle_group/1, Map.merge(defaults, Map.new(assigns)))
  end

  test "single mode renders a radiogroup of radio items" do
    html = render_toggle_group()
    buttons = Floki.parse_fragment!(html) |> Floki.find("[data-slot=toggle-group-item]")

    assert html =~ ~s(role="radiogroup")
    assert Floki.attribute(buttons, "role") == ["radio", "radio"]
    assert Floki.attribute(buttons, "aria-checked") == ["true", "false"]
    assert Floki.attribute(buttons, "tabindex") == ["0", "-1"]
  end

  test "default_value selects a matching single item" do
    html = render_toggle_group(%{default_value: "italic"})
    buttons = Floki.parse_fragment!(html) |> Floki.find("[data-slot=toggle-group-item]")
    assert Floki.attribute(buttons, "aria-checked") == ["false", "true"]
  end

  test "multiple mode renders a toolbar with aria-pressed" do
    html = render_toggle_group(%{type: :multiple, default_value: ~w(bold italic)})
    buttons = Floki.parse_fragment!(html) |> Floki.find("[data-slot=toggle-group-item]")

    assert html =~ ~s(role="toolbar")
    refute html =~ ~s(role="radio")
    assert Floki.attribute(buttons, "aria-pressed") == ["true", "true"]
    assert Floki.attribute(buttons, "tabindex") == ["0", "-1"]
  end

  test "selection runs client-side without a server round trip" do
    html = render_toggle_group()
    [first | _] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=toggle-group-item]")
    [command] = Floki.attribute(first, "phx-click")

    refute command =~ "push"
    assert command =~ "aria-checked"
    assert command =~ "data-state"
    assert command =~ "tabindex"
  end

  test "uses the UrUiToggleGroup hook with no inline script" do
    html = render_toggle_group()
    [root] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=toggle-group]")

    assert Floki.attribute(root, "phx-hook") == ["UrUiToggleGroup"]
    refute html =~ "<script"
    refute html =~ ~r/\son[a-z]+=/
  end

  test "items carry data-variant, data-size and data-spacing for outline border collapse" do
    html = render_toggle_group(%{variant: :outline, size: :sm})

    [first, second | _] =
      Floki.parse_fragment!(html) |> Floki.find("[data-slot=toggle-group-item]")

    assert Floki.attribute(first, "data-variant") == ["outline"]
    assert Floki.attribute(first, "data-size") == ["sm"]
    assert Floki.attribute(first, "data-spacing") == ["0"]
    assert Floki.attribute(second, "data-variant") == ["outline"]

    [class] = Floki.attribute(first, "class")
    assert class =~ ~s(data-[spacing=0]:data-[variant=outline]:border-l-0)
    assert class =~ ~s(data-[spacing=0]:data-[variant=outline]:first:border-l)
  end
end
