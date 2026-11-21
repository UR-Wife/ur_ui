defmodule UrUi.BadgeTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  @base "inline-flex items-center justify-center rounded-md border px-2 py-0.5 text-xs font-medium w-fit whitespace-nowrap shrink-0 [&>svg]:size-3 gap-1 [&>svg]:pointer-events-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive transition-[color,box-shadow] overflow-hidden"
  @variants %{
    default: "border-transparent bg-primary text-primary-foreground [a&]:hover:bg-primary/90",
    secondary:
      "border-transparent bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90",
    destructive:
      "border-transparent bg-destructive text-white [a&]:hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60",
    outline: "text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
    ghost:
      "border-transparent text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
    link: "border-transparent text-primary underline-offset-4 [a&]:hover:underline"
  }

  defp render_badge(assigns), do: render_component(&Components.badge/1, assigns)

  defp inner(content),
    do: %{__slot__: :inner_block, inner_block: fn _changed, _arg -> content end}

  defp assert_classes(html, variant \\ :default, custom \\ nil) do
    expected = [@base, @variants[variant], custom] |> Enum.reject(&is_nil/1) |> Enum.join(" ")
    [badge] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=badge]")
    assert Floki.attribute(badge, "class") == [expected]
  end

  describe "variants" do
    test "variant :default renders default classes and marker" do
      html = render_badge(%{inner_block: inner("New")})
      assert_classes(html)
      assert html =~ "data-variant=\"default\""
    end

    test "variant :secondary renders secondary classes and marker" do
      html = render_badge(%{variant: :secondary, inner_block: inner("New")})
      assert_classes(html, :secondary)
      assert html =~ "data-variant=\"secondary\""
    end

    test "variant :destructive renders destructive classes and marker" do
      html = render_badge(%{variant: :destructive, inner_block: inner("New")})
      assert_classes(html, :destructive)
      assert html =~ "data-variant=\"destructive\""
    end

    test "variant :outline renders outline classes and marker" do
      html = render_badge(%{variant: :outline, inner_block: inner("New")})
      assert_classes(html, :outline)
      assert html =~ "data-variant=\"outline\""
    end

    test "variant :ghost renders ghost classes and marker" do
      html = render_badge(%{variant: :ghost, inner_block: inner("New")})
      assert_classes(html, :ghost)
      assert html =~ "data-variant=\"ghost\""
    end

    test "variant :link renders link classes and marker" do
      html = render_badge(%{variant: :link, inner_block: inner("New")})
      assert_classes(html, :link)
      assert html =~ "data-variant=\"link\""
    end
  end

  describe "behaviour" do
    test "renders a span with only its inner content" do
      html = render_badge(%{inner_block: inner("Beta")})
      assert html =~ "<span"
      assert html =~ "Beta"
    end

    test "class extends base classes" do
      html = render_badge(%{class: "ml-2", inner_block: inner("Beta")})
      assert_classes(html, :default, "ml-2")
    end

    test "global attributes pass through" do
      html = render_badge(%{"aria-label": "status", id: "b1", inner_block: inner("Beta")})
      assert html =~ ~s(id="b1")
      assert html =~ ~s(aria-label="status")
    end
  end
end
