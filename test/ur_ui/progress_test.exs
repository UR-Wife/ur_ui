defmodule UrUi.ProgressTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  @base "relative h-2 w-full overflow-hidden rounded-full bg-primary/20"

  defp render_progress(assigns \\ %{}) do
    render_component(&Components.progress/1, Map.merge(%{id: "progress"}, Map.new(assigns)))
  end

  test "progress renders a progressbar with aria attributes" do
    html = render_progress(%{value: 60})

    assert html =~ ~s(role="progressbar")
    assert html =~ ~s(aria-valuemax="100")
    assert html =~ ~s(aria-valuemin="0")
    assert html =~ ~s(aria-valuenow="60")
    assert html =~ ~s(aria-valuetext="60%")
    assert html =~ ~s(data-state="loading")
    assert html =~ ~s(data-slot="progress")
    [root] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=progress]")
    assert Floki.attribute(root, "class") == [@base]
  end

  test "progress renders an indicator with the UrUiProgress hook" do
    html = render_progress(%{value: 60})
    [indicator] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=progress-indicator]")

    assert Floki.attribute(indicator, "phx-hook") == ["UrUiProgress"]

    assert Floki.attribute(indicator, "class") == [
             "h-full w-full flex-1 bg-primary transition-all"
           ]

    refute html =~ "style="
  end

  test "progress marks complete state and value-relative labels" do
    html = render_progress(%{value: 100})
    assert html =~ ~s(data-state="complete")
    assert html =~ ~s(aria-valuetext="100%")

    html = render_progress(%{value: 5, max: 20})
    assert html =~ ~s(data-state="loading")
    assert html =~ ~s(aria-valuetext="25%")
  end

  test "progress extends classes and passes global attrs" do
    html = render_progress(%{class: "w-64", "data-testid": "bar"})

    assert Floki.parse_fragment!(html)
           |> Floki.find("[data-slot=progress]")
           |> Floki.attribute("class") == ["#{@base} w-64"]

    assert html =~ ~s(data-testid="bar")
  end
end
