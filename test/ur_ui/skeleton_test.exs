defmodule UrUi.SkeletonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  @base "bg-accent animate-pulse rounded-md"

  defp render_skeleton(assigns), do: render_component(&Components.skeleton/1, assigns)

  defp assert_classes(html, custom \\ nil) do
    expected = [@base, custom] |> Enum.reject(&is_nil/1) |> Enum.join(" ")
    [skeleton] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=skeleton]")
    assert Floki.attribute(skeleton, "class") == [expected]
  end

  describe "skeleton" do
    test "renders a div with skeleton classes and no attrs at all" do
      html = render_skeleton(%{})
      assert html =~ "<div"
      assert_classes(html)
    end

    test "renders inner content when given" do
      inner = %{__slot__: :inner_block, inner_block: fn _changed, _arg -> "loading" end}
      html = render_skeleton(%{inner_block: inner})
      assert html =~ "loading"
    end

    test "class extends base classes" do
      html = render_skeleton(%{class: "h-4 w-32"})
      assert_classes(html, "h-4 w-32")
    end

    test "global attributes pass through" do
      html = render_skeleton(%{id: "sk1", "aria-hidden": "true"})
      assert html =~ ~s(id="sk1")
      assert html =~ ~s(aria-hidden="true")
    end
  end
end
