defmodule UrUi.SkeletonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  defp render_skeleton(assigns), do: render_component(&Components.skeleton/1, assigns)

  describe "skeleton" do
    test "renders a div with skeleton classes and no attrs at all" do
      html = render_skeleton(%{})
      assert html =~ "<div"
      assert html =~ "ur-skeleton"
    end

    test "renders inner content when given" do
      inner = %{__slot__: :inner_block, inner_block: fn _changed, _arg -> "loading" end}
      html = render_skeleton(%{inner_block: inner})
      assert html =~ "loading"
    end

    test "class extends base classes" do
      html = render_skeleton(%{class: "h-4 w-32"})
      assert html =~ "ur-skeleton"
      assert html =~ "h-4"
      assert html =~ "w-32"
    end

    test "global attributes pass through" do
      html = render_skeleton(%{id: "sk1", "aria-hidden": "true"})
      assert html =~ ~s(id="sk1")
      assert html =~ ~s(aria-hidden="true")
    end
  end
end
