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

  test "aspect_ratio wraps content in a relative frame and an absolute fill" do
    html = render_aspect_ratio()

    assert html =~ ~s(class="relative w-full aspect-square")
    [inner] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=aspect-ratio]")
    assert Floki.attribute(inner, "class") == ["absolute inset-0"]
  end

  test "aspect_ratio maps common ratios to built-in utilities" do
    html = render_aspect_ratio(%{ratio: "16/9"})
    assert html =~ ~s(class="relative w-full aspect-video")

    html = render_aspect_ratio(%{ratio: "4/3"})
    assert html =~ "aspect-[4/3]"
  end

  test "aspect_ratio leaves unknown ratios to the caller" do
    html = render_aspect_ratio(%{ratio: "5/4"})
    assert html =~ ~s(class="relative w-full")
  end

  test "aspect_ratio extends the frame class" do
    html = render_aspect_ratio(%{class: "w-64", inner_block: inner("x")})

    assert html =~ ~s(class="relative w-full aspect-square w-64")
  end
end
