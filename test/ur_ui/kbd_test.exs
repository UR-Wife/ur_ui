defmodule UrUi.KbdTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  @base "pointer-events-none inline-flex h-5 w-fit min-w-5 items-center justify-center gap-1 rounded-sm bg-muted px-1 font-sans text-xs font-medium text-muted-foreground select-none [&_svg:not([class*='size-'])]:size-3 [[data-slot=tooltip-content]_&]:bg-background/20 [[data-slot=tooltip-content]_&]:text-background dark:[[data-slot=tooltip-content]_&]:bg-background/10"

  defp render_kbd(assigns), do: render_component(&Components.kbd/1, assigns)

  defp inner(content),
    do: %{__slot__: :inner_block, inner_block: fn _changed, _arg -> content end}

  defp assert_kbd_classes(html, custom \\ nil) do
    expected = [@base, custom] |> Enum.reject(&is_nil/1) |> Enum.join(" ")
    [kbd] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=kbd]")
    assert Floki.attribute(kbd, "class") == [expected]
  end

  test "kbd renders a key with shadcn's base classes" do
    html = render_kbd(%{inner_block: inner("K")})

    assert html =~ "<kbd"
    assert html =~ "K"
    assert html =~ ~s(data-slot="kbd")
    assert_kbd_classes(html)
  end

  test "kbd extends classes and passes global attrs" do
    html = render_kbd(%{class: "extra", "data-testid": "kbd", inner_block: inner("⌘")})

    assert_kbd_classes(html, "extra")
    assert html =~ ~s(data-testid="kbd")
  end

  test "kbd_group renders a key combination wrapper" do
    html = render_component(&Components.kbd_group/1, %{inner_block: inner("AB")})

    assert html =~ ~s(data-slot="kbd-group")
    assert html =~ ~s(class="inline-flex items-center gap-1")
    assert html =~ "AB"
  end
end
