defmodule UrUi.PaginationTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  defp inner(content),
    do: %{__slot__: :inner_block, inner_block: fn _changed, _arg -> content end}

  test "pagination renders a navigation labelled for assistive tech" do
    html = render_component(&Components.pagination/1, %{inner_block: inner("x")})

    assert html =~ "<nav"
    assert html =~ ~s(role="navigation")
    assert html =~ ~s(aria-label="pagination")
    assert html =~ ~s(data-slot="pagination")
    assert html =~ "mx-auto flex w-full justify-center"
  end

  test "pagination_content renders an unordered list" do
    html = render_component(&Components.pagination_content/1, %{inner_block: inner("x")})

    assert html =~ "<ul"
    assert html =~ ~s(data-slot="pagination-content")
    assert html =~ "flex flex-row items-center gap-1"
  end

  test "pagination_link renders an active outline link with aria-current" do
    html =
      render_component(&Components.pagination_link/1, %{
        href: "#",
        is_active: true,
        inner_block: inner("1")
      })

    assert html =~ ~s(href="#")
    assert html =~ ~s(aria-current="page")
    assert html =~ ~s(data-slot="pagination-link")
    assert html =~ "border bg-background shadow-xs"
    assert html =~ "size-9"
  end

  test "pagination_link renders a ghost link when inactive" do
    html =
      render_component(&Components.pagination_link/1, %{href: "#", inner_block: inner("2")})

    refute html =~ "aria-current"
    assert html =~ "hover:bg-accent hover:text-accent-foreground"
  end

  test "pagination_previous and next render labelled arrow links" do
    prev = render_component(&Components.pagination_previous/1, %{href: "#"})
    assert prev =~ ~s(aria-label="Go to previous page")
    assert prev =~ ~s(<path d="m15 18-6-6 6-6")
    assert prev =~ "Previous"

    nxt = render_component(&Components.pagination_next/1, %{href: "#"})
    assert nxt =~ ~s(aria-label="Go to next page")
    assert nxt =~ ~s(<path d="m9 18 6-6-6-6")
    assert nxt =~ "Next"
  end

  test "pagination_ellipsis is decorative with a More pages label" do
    html = render_component(&Components.pagination_ellipsis/1, %{})

    assert html =~ ~s(aria-hidden="true")
    assert html =~ ~s(data-slot="pagination-ellipsis")
    assert html =~ "More pages"
  end
end
