defmodule UrUi.BadgeTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  defp render_badge(assigns), do: render_component(&Components.badge/1, assigns)

  defp inner(content),
    do: %{__slot__: :inner_block, inner_block: fn _changed, _arg -> content end}

  describe "variants" do
    test "variant :default renders default classes and marker" do
      html = render_badge(%{inner_block: inner("New")})
      assert html =~ "ur-badge"
      assert html =~ "ur-badge--default"
      assert html =~ "data-variant=\"default\""
    end

    test "variant :secondary renders secondary classes and marker" do
      html = render_badge(%{variant: :secondary, inner_block: inner("New")})
      assert html =~ "ur-badge--secondary"
      assert html =~ "data-variant=\"secondary\""
    end

    test "variant :destructive renders destructive classes and marker" do
      html = render_badge(%{variant: :destructive, inner_block: inner("New")})
      assert html =~ "ur-badge--destructive"
      assert html =~ "data-variant=\"destructive\""
    end

    test "variant :outline renders outline classes and marker" do
      html = render_badge(%{variant: :outline, inner_block: inner("New")})
      assert html =~ "ur-badge--outline"
      assert html =~ "data-variant=\"outline\""
    end

    test "variant :ghost renders ghost classes and marker" do
      html = render_badge(%{variant: :ghost, inner_block: inner("New")})
      assert html =~ "ur-badge--ghost"
      assert html =~ "data-variant=\"ghost\""
    end

    test "variant :link renders link classes and marker" do
      html = render_badge(%{variant: :link, inner_block: inner("New")})
      assert html =~ "ur-badge--link"
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
      assert html =~ "ur-badge"
      assert html =~ "ml-2"
    end

    test "global attributes pass through" do
      html = render_badge(%{"aria-label": "status", id: "b1", inner_block: inner("Beta")})
      assert html =~ ~s(id="b1")
      assert html =~ ~s(aria-label="status")
    end
  end
end
