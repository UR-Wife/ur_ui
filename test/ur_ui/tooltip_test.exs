defmodule UrUi.TooltipTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  @content_base "z-50 w-fit origin-(--radix-tooltip-content-transform-origin) rounded-md bg-foreground px-3 py-1.5 text-xs text-balance text-background"

  defp inner(content), do: %{__slot__: :inner_block, inner_block: fn _changed, _arg -> content end}

  defp render_provider(assigns \\ %{}) do
    defaults = %{inner_block: inner("wrapped")}
    render_component(&Components.tooltip_provider/1, Map.merge(defaults, Map.new(assigns)))
  end

  defp render_tooltip(assigns \\ %{}) do
    defaults = %{
      id: "tooltip",
      inner_block: inner("<button data-slot=\"tooltip-trigger\">Hover</button>")
    }

    render_component(&Components.tooltip/1, Map.merge(defaults, Map.new(assigns)))
  end

  defp render_trigger(assigns \\ %{}) do
    defaults = %{inner_block: inner("Hover")}
    render_component(&Components.tooltip_trigger/1, Map.merge(defaults, Map.new(assigns)))
  end

  defp render_content(assigns \\ %{}) do
    defaults = %{id: "tooltip-content", inner_block: inner("Add to library")}
    render_component(&Components.tooltip_content/1, Map.merge(defaults, Map.new(assigns)))
  end

  test "tooltip_provider wraps its children and carries the hover delay" do
    html = render_provider(%{delay_duration: 700})

    [provider] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=tooltip-provider]")
    assert Floki.attribute(provider, "data-delay-duration") == ["700"]
    assert Floki.text(provider) =~ "wrapped"
  end

  test "tooltip_provider defaults the hover delay to zero" do
    html = render_provider()
    [provider] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=tooltip-provider]")
    assert Floki.attribute(provider, "data-delay-duration") == ["0"]
  end

  test "tooltip renders a closed, hook-wired wrapper around its trigger" do
    html = render_tooltip()
    [root] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=tooltip]")

    assert Floki.attribute(root, "id") == ["tooltip"]
    assert Floki.attribute(root, "data-state") == ["closed"]
    assert Floki.attribute(root, "phx-hook") == ["UrUiTooltip"]
    assert Floki.attribute(root, "class") == ["inline-block"]
    refute html =~ "<script"
    refute html =~ ~r/\son[a-z]+=/
  end

  test "tooltip delay_duration overrides the provider and is omitted when unset" do
    html = render_tooltip(%{delay_duration: 250})
    [root] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=tooltip]")
    assert Floki.attribute(root, "data-delay-duration") == ["250"]

    html = render_tooltip()
    [root] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=tooltip]")
    assert Floki.attribute(root, "data-delay-duration") == []
  end

  test "tooltip_trigger renders a plain button with the shadcn slot and state" do
    html = render_trigger()
    [button] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=tooltip-trigger]")

    assert Floki.attribute(button, "type") == ["button"]
    assert Floki.attribute(button, "data-state") == ["closed"]
    assert Floki.attribute(button, "aria-describedby") == []
    assert Floki.text(button) =~ "Hover"
  end

  test "tooltip_content renders role=tooltip with side and offset, hidden by default" do
    html = render_content(%{side: :bottom, side_offset: 4})
    [content] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=tooltip-content]")

    assert Floki.attribute(content, "id") == ["tooltip-content"]
    assert Floki.attribute(content, "role") == ["tooltip"]
    assert Floki.attribute(content, "data-state") == ["closed"]
    assert Floki.attribute(content, "data-side") == ["bottom"]
    assert Floki.attribute(content, "data-side-offset") == ["4"]
    assert Floki.attribute(content, "hidden") != []
    assert Floki.text(content) =~ "Add to library"
  end

  test "tooltip_content defaults side to top and offset to zero" do
    html = render_content()
    [content] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=tooltip-content]")

    assert Floki.attribute(content, "data-side") == ["top"]
    assert Floki.attribute(content, "data-side-offset") == ["0"]
  end

  test "tooltip_content uses shadcn's exact content classes and renders the arrow" do
    html = render_content()
    [content] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=tooltip-content]")
    [class] = Floki.attribute(content, "class")

    assert class =~ @content_base
    assert class =~ "data-[state=closed]:animate-out"

    assert Floki.find(Floki.parse_fragment!(html), "[data-slot=tooltip-arrow]") != []
  end
end
