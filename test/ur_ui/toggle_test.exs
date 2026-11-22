defmodule UrUi.ToggleTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  @base "inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap transition-[color,box-shadow] outline-none hover:bg-muted hover:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"

  defp inner(content),
    do: %{__slot__: :inner_block, inner_block: fn _changed, _arg -> content end}

  defp render_toggle(assigns \\ %{}),
    do: render_component(&Components.toggle/1, Map.put(assigns, :inner_block, inner("Bold")))

  defp assert_classes(html, expected) do
    [button] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=toggle]")
    assert Floki.attribute(button, "class") == [expected]
  end

  test "toggle renders an unpressed button with shadcn's classes" do
    html = render_toggle()

    assert html =~ "<button"
    assert html =~ ~s(type="button")
    assert html =~ ~s(data-slot="toggle")
    assert html =~ ~s(data-state="off")
    assert html =~ ~s(aria-pressed="false")
    assert_classes(html, "#{@base} bg-transparent h-9 min-w-9 px-2")
  end

  test "toggle renders pressed state and toggles on the client" do
    html = render_toggle(%{pressed: true})
    [button] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=toggle]")

    assert html =~ ~s(data-state="on")
    assert html =~ ~s(aria-pressed="true")

    [command] = Floki.attribute(button, "phx-click")
    refute command =~ "push"
    assert command =~ "aria-pressed"
    assert command =~ "data-state"
  end

  test "toggle applies variants and sizes" do
    html = render_toggle(%{variant: :outline, size: :sm})

    assert html =~
             "border border-input bg-transparent shadow-xs hover:bg-accent hover:text-accent-foreground"

    assert html =~ "h-8 min-w-8 px-1.5"
  end

  test "toggle disabled renders disabled with no click command" do
    html = render_toggle(%{disabled: true})
    [button] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=toggle]")

    assert html =~ ~s(disabled)
    assert html =~ ~s(data-disabled="")
    assert Floki.attribute(button, "phx-click") == []
  end

  test "toggle passes global attrs" do
    html = render_toggle(%{"aria-label": "Bold", id: "b1"})

    assert html =~ ~s(aria-label="Bold")
    assert html =~ ~s(id="b1")
  end
end
