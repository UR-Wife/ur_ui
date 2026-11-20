defmodule UrUi.LabelTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  @base "flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50"

  defp render_label(assigns), do: render_component(&Components.label/1, assigns)

  defp inner(content),
    do: %{__slot__: :inner_block, inner_block: fn _changed, _arg -> content end}

  defp assert_classes(html, custom \\ nil) do
    expected = [@base, custom] |> Enum.reject(&is_nil/1) |> Enum.join(" ")
    [label] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=label]")
    assert Floki.attribute(label, "class") == [expected]
  end

  describe "label" do
    test "renders a label with its inner content" do
      html = render_label(%{inner_block: inner("Email")})
      assert html =~ "<label"
      assert_classes(html)
      assert html =~ "Email"
    end

    test "for attribute renders when given" do
      html = render_label(%{for: "user_email", inner_block: inner("Email")})
      assert html =~ ~s(for="user_email")
    end

    test "for attribute is omitted when missing" do
      html = render_label(%{inner_block: inner("Email")})
      refute html =~ "for="
    end

    test "class extends base classes" do
      html = render_label(%{class: "mt-1", inner_block: inner("Email")})
      assert_classes(html, "mt-1")
    end

    test "global attributes pass through" do
      html = render_label(%{"aria-label": "L", id: "l1", inner_block: inner("Email")})
      assert html =~ ~s(id="l1")
      assert html =~ ~s(aria-label="L")
    end
  end
end
