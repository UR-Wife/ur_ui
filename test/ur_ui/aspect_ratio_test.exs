defmodule UrUi.AspectRatioTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  defp inner(content),
    do: %{__slot__: :inner_block, inner_block: fn _changed, _arg -> content end}

  defp render_aspect_ratio(assigns \\ %{}) do
    assigns = Map.put_new(assigns, :inner_block, inner("x"))
    render_component(&Components.aspect_ratio/1, assigns)
  end

  test "aspect_ratio defaults to a square" do
    html = render_aspect_ratio()

    assert html =~ ~s(data-slot="aspect-ratio")
    assert html =~ "aspect-square w-full"
    assert html =~ "x"
  end

  test "aspect_ratio maps common ratios to built-in utilities" do
    html = render_aspect_ratio(%{ratio: "16/9"})
    assert html =~ "aspect-video w-full"

    html = render_aspect_ratio(%{ratio: "4/3"})
    assert html =~ "aspect-[4/3]"
  end

  test "aspect_ratio uses an arbitrary value for other ratios" do
    html = render_aspect_ratio(%{ratio: "2/1"})
    assert html =~ "aspect-[2/1]"
  end

  test "aspect_ratio extends classes" do
    html = render_aspect_ratio(%{class: "w-64", inner_block: inner("x")})

    assert html =~ "aspect-square w-full w-64"
  end
end
