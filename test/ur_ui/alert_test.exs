defmodule UrUi.AlertTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @component UrUi.Components
  @base "relative w-full rounded-lg border px-4 py-3 text-sm grid has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr] grid-cols-[0_1fr] has-[>svg]:gap-x-3 gap-y-0.5 items-start [&>svg]:size-4 [&>svg]:translate-y-0.5 [&>svg]:text-current"
  @variants %{
    default: "bg-card text-card-foreground",
    destructive:
      "text-destructive bg-card [&>svg]:text-current *:data-[slot=alert-description]:text-destructive/90"
  }
  @title_classes "col-start-2 line-clamp-1 min-h-4 font-medium tracking-tight"
  @description_classes "text-muted-foreground col-start-2 grid justify-items-start gap-1 text-sm [&_p]:leading-relaxed"

  defp inner(content) do
    %{__slot__: :inner_block, inner_block: fn _changed, _argument -> content end}
  end

  defp render_part(name, assigns, content) do
    assigns = assigns |> Map.new() |> Map.put_new(:inner_block, [inner(content)])
    render_component(Function.capture(@component, name, 1), assigns)
  end

  defp assert_classes(html, slot, expected) do
    [alert] = Floki.parse_fragment!(html) |> Floki.find("[data-slot='#{slot}']")
    assert Floki.attribute(alert, "class") == [expected]
  end

  test "default alert renders an assertive live region" do
    html = render_part(:alert, %{variant: :default}, "Update available")

    assert html =~ ~s(role="alert")
    assert html =~ ~s(data-variant="default")
    assert_classes(html, "alert", "#{@base} #{@variants.default}")
    assert html =~ "Update available"
  end

  test "destructive alert renders the destructive variant" do
    html = render_part(:alert, %{variant: :destructive}, "Delete failed")

    assert html =~ ~s(data-variant="destructive")
    assert_classes(html, "alert", "#{@base} #{@variants.destructive}")
    assert html =~ "Delete failed"
  end

  test "alert_title renders the title slot" do
    html = render_part(:alert_title, %{}, "Heads up")

    assert_classes(html, "alert-title", @title_classes)
    assert html =~ "Heads up"
  end

  test "alert_description renders the description slot" do
    html = render_part(:alert_description, %{}, "More detail")

    assert_classes(html, "alert-description", @description_classes)
    assert html =~ "More detail"
  end

  test "alert extends classes and passes global attrs" do
    html = render_part(:alert, %{class: "extra", id: "status", "aria-live": "polite"}, "Saved")

    assert_classes(html, "alert", "#{@base} #{@variants.default} extra")
    assert html =~ ~s(id="status")
    assert html =~ ~s(aria-live="polite")
  end

  test "alert renders with no optional attrs or content" do
    html = render_component(Function.capture(@component, :alert, 1), %{inner_block: []})

    assert html =~ ~s(role="alert")
    assert html =~ ~s(data-variant="default")
  end
end
