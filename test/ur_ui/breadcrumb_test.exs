defmodule UrUi.BreadcrumbTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  defp inner(content),
    do: %{__slot__: :inner_block, inner_block: fn _changed, _arg -> content end}

  defp render_breadcrumb(assigns \\ %{}), do: render_component(&Components.breadcrumb/1, assigns)

  test "breadcrumb renders a nav labelled for assistive tech" do
    html = render_breadcrumb(%{inner_block: inner("Home")})

    assert html =~ "<nav"
    assert html =~ ~s(aria-label="breadcrumb")
    assert html =~ ~s(data-slot="breadcrumb")
    assert html =~ "Home"
  end

  test "breadcrumb_list renders an ordered list with shadcn's classes" do
    html = render_component(&Components.breadcrumb_list/1, %{inner_block: inner("x")})

    assert html =~ "<ol"
    assert html =~ ~s(data-slot="breadcrumb-list")

    assert html =~
             "flex flex-wrap items-center gap-1.5 text-sm break-words text-muted-foreground sm:gap-2.5"
  end

  test "breadcrumb_page marks the current page with ARIA" do
    html = render_component(&Components.breadcrumb_page/1, %{inner_block: inner("Current")})

    assert html =~ ~s(data-slot="breadcrumb-page")
    assert html =~ ~s(role="link")
    assert html =~ ~s(aria-disabled="true")
    assert html =~ ~s(aria-current="page")
    assert html =~ "Current"
  end

  test "breadcrumb_item renders an li with shadcn's classes" do
    html = render_component(&Components.breadcrumb_item/1, %{inner_block: inner("Home")})

    assert html =~ "<li"
    assert html =~ ~s(data-slot="breadcrumb-item")
    assert html =~ "inline-flex items-center gap-1.5"
    assert html =~ "Home"
  end

  test "breadcrumb_separator renders custom content from its slot" do
    html =
      render_component(&Components.breadcrumb_separator/1, %{inner_block: inner("sep")})

    assert html =~ "sep"
    refute html =~ "m9 18 6-6-6-6"
  end

  test "breadcrumb_link renders an anchor with href" do
    html =
      render_component(&Components.breadcrumb_link/1, %{href: "/", inner_block: inner("Home")})

    assert html =~ ~s(href="/")
    assert html =~ ~s(data-slot="breadcrumb-link")
  end

  test "breadcrumb_separator is decorative with a chevron" do
    html = render_component(&Components.breadcrumb_separator/1, %{})

    assert html =~ ~s(data-slot="breadcrumb-separator")
    assert html =~ ~s(role="presentation")
    assert html =~ ~s(aria-hidden="true")
    assert html =~ ~s(<path d="m9 18 6-6-6-6")
  end

  test "breadcrumb_ellipsis is decorative with a More label" do
    html = render_component(&Components.breadcrumb_ellipsis/1, %{})

    assert html =~ ~s(data-slot="breadcrumb-ellipsis")
    assert html =~ ~s(role="presentation")
    assert html =~ ~s(aria-hidden="true")
    assert html =~ "More"
  end
end
