defmodule UrUi.SeparatorTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  @base "bg-border shrink-0 data-[orientation=horizontal]:h-px data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-px"

  defp render_separator(assigns), do: render_component(&Components.separator/1, assigns)

  defp assert_classes(html, custom \\ nil) do
    expected = [@base, custom] |> Enum.reject(&is_nil/1) |> Enum.join(" ")
    [separator] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=separator]")
    assert Floki.attribute(separator, "class") == [expected]
  end

  describe "orientation" do
    test "defaults to horizontal" do
      html = render_separator(%{})
      assert_classes(html)
      assert html =~ ~s(data-orientation="horizontal")
    end

    test "orientation :vertical renders vertical classes and marker" do
      html = render_separator(%{orientation: :vertical})
      assert_classes(html)
      assert html =~ ~s(data-orientation="vertical")
    end
  end

  describe "semantics" do
    test "decorative by default: role none only, as Radix renders it" do
      html = render_separator(%{})
      assert html =~ ~s(role="none")
      refute html =~ "aria-hidden"
      refute html =~ "aria-orientation"
      refute html =~ ~s(role="separator")
    end

    test "decorative: false vertical exposes role separator with aria-orientation" do
      html = render_separator(%{decorative: false, orientation: :vertical})
      assert html =~ ~s(role="separator")
      assert html =~ ~s(aria-orientation="vertical")
      refute html =~ ~s(role="none")
    end

    test "decorative: false horizontal omits aria-orientation (the ARIA default)" do
      html = render_separator(%{decorative: false})
      assert html =~ ~s(role="separator")
      refute html =~ "aria-orientation"
    end
  end

  describe "behaviour" do
    test "class extends base classes" do
      html = render_separator(%{class: "my-4"})
      assert_classes(html, "my-4")
    end

    test "global attributes pass through" do
      html = render_separator(%{id: "s1", "data-testid": "sep"})
      assert html =~ ~s(id="s1")
      assert html =~ ~s(data-testid="sep")
    end
  end
end
