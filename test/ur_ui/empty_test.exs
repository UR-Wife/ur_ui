defmodule UrUi.EmptyTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  defp inner(content),
    do: %{__slot__: :inner_block, inner_block: fn _changed, _arg -> content end}

  test "empty renders shadcn's base classes" do
    html = render_component(&Components.empty/1, %{inner_block: inner("x")})

    assert html =~ ~s(data-slot="empty")

    assert html =~
             "flex min-w-0 flex-1 flex-col items-center justify-center gap-6 rounded-lg border-dashed p-6 text-center text-balance md:p-12"
  end

  test "empty_media applies the icon variant" do
    html = render_component(&Components.empty_media/1, %{variant: :icon, inner_block: inner("i")})

    assert html =~ ~s(data-slot="empty-icon")
    assert html =~ ~s(data-variant="icon")
    assert html =~ "size-10"
    assert html =~ "rounded-lg bg-muted"
  end

  test "empty_title and empty_description render their slots" do
    title = render_component(&Components.empty_title/1, %{inner_block: inner("No results")})
    assert title =~ ~s(data-slot="empty-title")
    assert title =~ "text-lg font-medium tracking-tight"
    assert title =~ "No results"

    desc = render_component(&Components.empty_description/1, %{inner_block: inner("Try again")})
    assert desc =~ ~s(data-slot="empty-description")
    assert desc =~ "text-muted-foreground"
    assert desc =~ "Try again"
  end
end
