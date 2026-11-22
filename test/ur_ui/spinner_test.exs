defmodule UrUi.SpinnerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  defp render_spinner(assigns \\ %{}), do: render_component(&Components.spinner/1, assigns)

  test "spinner renders an accessible loading svg" do
    html = render_spinner()

    assert html =~ "<svg"
    assert html =~ ~s(role="status")
    assert html =~ ~s(aria-label="Loading")
    assert html =~ ~s(data-slot="spinner")
    assert html =~ "size-4 animate-spin"
    assert html =~ ~s(<path d="M21 12a9 9 0 1 1-6.219-8.56")
  end

  test "spinner extends classes and passes global attrs" do
    html = render_spinner(%{class: "size-8", "data-testid": "spinner"})

    assert html =~ "size-4 animate-spin size-8"
    assert html =~ ~s(data-testid="spinner")
  end
end
