defmodule UrUi.SeparatorTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  defp render_separator(assigns), do: render_component(&Components.separator/1, assigns)

  describe "orientation" do
    test "defaults to horizontal" do
      html = render_separator(%{})
      assert html =~ "ur-separator"
      assert html =~ "ur-separator--horizontal"
      assert html =~ ~s(data-orientation="horizontal")
    end

    test "orientation :vertical renders vertical classes and marker" do
      html = render_separator(%{orientation: :vertical})
      assert html =~ "ur-separator--vertical"
      assert html =~ ~s(data-orientation="vertical")
    end
  end

  describe "semantics" do
    test "decorative by default: role none, hidden from accessibility tree" do
      html = render_separator(%{})
      assert html =~ ~s(role="none")
      assert html =~ ~s(aria-hidden="true")
      refute html =~ ~s(role="separator")
    end

    test "decorative: false exposes role separator with aria-orientation" do
      html = render_separator(%{decorative: false, orientation: :vertical})
      assert html =~ ~s(role="separator")
      assert html =~ ~s(aria-orientation="vertical")
      refute html =~ ~s(role="none")
    end
  end

  describe "behaviour" do
    test "class extends base classes" do
      html = render_separator(%{class: "my-4"})
      assert html =~ "ur-separator"
      assert html =~ "my-4"
    end

    test "global attributes pass through" do
      html = render_separator(%{id: "s1", "data-testid": "sep"})
      assert html =~ ~s(id="s1")
      assert html =~ ~s(data-testid="sep")
    end
  end
end
