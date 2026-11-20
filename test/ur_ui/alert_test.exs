defmodule UrUi.AlertTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @component UrUi.Components

  defp inner(content) do
    %{__slot__: :inner_block, inner_block: fn _changed, _argument -> content end}
  end

  defp render_part(name, assigns, content) do
    assigns = assigns |> Map.new() |> Map.put_new(:inner_block, [inner(content)])
    render_component(Function.capture(@component, name, 1), assigns)
  end

  test "default alert renders an assertive live region" do
    html = render_part(:alert, %{variant: :default}, "Update available")

    assert html =~ ~s(role="alert")
    assert html =~ ~s(data-slot="alert")
    assert html =~ ~s(data-variant="default")
    assert html =~ "ur-alert--default"
    assert html =~ "Update available"
  end

  test "destructive alert renders the destructive variant" do
    html = render_part(:alert, %{variant: :destructive}, "Delete failed")

    assert html =~ ~s(data-variant="destructive")
    assert html =~ "ur-alert--destructive"
    assert html =~ "Delete failed"
  end

  test "alert_title renders the title slot" do
    html = render_part(:alert_title, %{}, "Heads up")

    assert html =~ ~s(data-slot="alert-title")
    assert html =~ "ur-alert__title"
    assert html =~ "Heads up"
  end

  test "alert_description renders the description slot" do
    html = render_part(:alert_description, %{}, "More detail")

    assert html =~ ~s(data-slot="alert-description")
    assert html =~ "ur-alert__description"
    assert html =~ "More detail"
  end

  test "alert extends classes and passes global attrs" do
    html = render_part(:alert, %{class: "extra", id: "status", "aria-live": "polite"}, "Saved")

    assert html =~ "ur-alert"
    assert html =~ "extra"
    assert html =~ ~s(id="status")
    assert html =~ ~s(aria-live="polite")
  end

  test "alert renders with no optional attrs or content" do
    html = render_component(Function.capture(@component, :alert, 1), %{inner_block: []})

    assert html =~ ~s(role="alert")
    assert html =~ ~s(data-variant="default")
  end
end
