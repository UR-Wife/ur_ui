defmodule UrUi.BadgeTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  @base "inline-flex w-fit shrink-0 items-center justify-center gap-1 overflow-hidden rounded-full border border-transparent px-2 py-0.5 text-xs font-medium whitespace-nowrap transition-[color,box-shadow] focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 [&>svg]:pointer-events-none [&>svg]:size-3"
  @variants %{
    default: "bg-primary text-primary-foreground [a&]:hover:bg-primary/90",
    secondary: "bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90",
    destructive:
      "bg-destructive text-white focus-visible:ring-destructive/20 dark:bg-destructive/60 dark:focus-visible:ring-destructive/40 [a&]:hover:bg-destructive/90",
    outline:
      "border-border text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
    ghost: "[a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
    link: "text-primary underline-offset-4 [a&]:hover:underline"
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
