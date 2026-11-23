defmodule UrUi.SliderTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  @base "relative flex w-full touch-none items-center select-none data-[disabled]:opacity-50 data-[orientation=vertical]:h-full data-[orientation=vertical]:min-h-44 data-[orientation=vertical]:w-auto data-[orientation=vertical]:flex-col"

  defp render_slider(assigns \\ %{}) do
    render_component(&Components.slider/1, Map.merge(%{"aria-label": "Volume", id: "volume"}, Map.new(assigns)))
  end

  test "slider renders a named role=slider thumb with shadcn's classes" do
    html = render_slider()

    [root] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=slider]")
    assert Floki.attribute(root, "id") == ["volume"]
    assert Floki.attribute(root, "data-orientation") == ["horizontal"]
    assert Floki.attribute(root, "class") == [@base]
    assert Floki.attribute(root, "phx-hook") == ["UrUiSlider"]

    [thumb] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=slider-thumb]")
    assert Floki.attribute(thumb, "role") == ["slider"]
    assert Floki.attribute(thumb, "aria-label") == ["Volume"]
    assert Floki.attribute(thumb, "aria-valuemin") == ["0"]
    assert Floki.attribute(thumb, "aria-valuemax") == ["100"]
    assert Floki.attribute(thumb, "aria-valuenow") == ["50"]
    assert Floki.attribute(thumb, "aria-orientation") == ["horizontal"]
    assert Floki.attribute(thumb, "tabindex") == ["0"]
  end

  test "slider renders the track and range with shadcn's classes" do
    html = render_slider()
    fragment = Floki.parse_fragment!(html)

    [track] = Floki.find(fragment, "[data-slot=slider-track]")
    assert Floki.attribute(track, "class") == [
             "relative grow overflow-hidden rounded-full bg-muted data-[orientation=horizontal]:h-1.5 data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-1.5"
           ]

    [range] = Floki.find(fragment, "[data-slot=slider-range]")
    assert Floki.attribute(range, "class") == [
             "absolute bg-primary data-[orientation=horizontal]:h-full data-[orientation=vertical]:w-full"
           ]

    refute html =~ "style="
  end

  test "slider swaps value and orientation attrs" do
    html = render_slider(%{default_value: 75, min: 10, max: 90, orientation: :vertical})

    assert html =~ ~s(data-value="75")
    assert html =~ ~s(data-orientation="vertical")
    assert html =~ ~s(aria-valuemin="10")
    assert html =~ ~s(aria-valuemax="90")
    assert html =~ ~s(aria-valuenow="75")
    assert html =~ ~s(aria-orientation="vertical")
  end

  test "a disabled slider removes the thumb tabindex and adds data-disabled" do
    html = render_slider(%{disabled: true})

    assert html =~ ~s(data-disabled="")
    assert html =~ ~s(aria-disabled="true")

    [thumb] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=slider-thumb]")
    assert Floki.attribute(thumb, "tabindex") == []
  end

  test "slider extends classes and passes global attrs" do
    html = render_slider(%{class: "w-64", id: "vol", "data-volume": "loud"})

    [root] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=slider]")
    assert Floki.attribute(root, "class") == ["#{@base} w-64"]
    assert Floki.attribute(root, "id") == ["vol"]
    assert Floki.attribute(root, "data-volume") == ["loud"]
  end

  test "slider omits the aria-label on the thumb when none is given" do
    html = render_component(&Components.slider/1, %{id: "volume"})

    assert html =~ ~s(role="slider")

    [thumb] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=slider-thumb]")
    assert Floki.attribute(thumb, "aria-label") == []
  end

  test "slider requires a stable id" do
    assert_raise KeyError, ~r/key :id not found/, fn ->
      render_component(&Components.slider/1, %{})
    end
  end

  test "slider forwards aria-labelledby and aria-valuetext to the thumb" do
    html =
      render_slider(%{"aria-labelledby": "volume-label", "aria-valuetext": "loud", "aria-describedby": "volume-hint"})

    [root] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=slider]")
    refute Floki.attribute(root, "aria-labelledby") |> List.first()
    refute Floki.attribute(root, "aria-valuetext") |> List.first()
    refute Floki.attribute(root, "aria-describedby") |> List.first()

    [thumb] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=slider-thumb]")
    assert Floki.attribute(thumb, "aria-labelledby") == ["volume-label"]
    assert Floki.attribute(thumb, "aria-valuetext") == ["loud"]
    assert Floki.attribute(thumb, "aria-describedby") == ["volume-hint"]
  end
end
