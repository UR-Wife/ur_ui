defmodule UrUi.CollapsibleTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  defp slot(name, content) do
    %{__slot__: name, inner_block: fn _changed, _arg -> content end}
  end

  defp render_collapsible(assigns \\ %{}) do
    defaults = %{
      id: "faq",
      trigger: [slot(:trigger, "Question")],
      content: [slot(:content, "Answer")]
    }

    render_component(
      &Components.collapsible/1,
      Map.merge(defaults, Map.new(assigns))
    )
  end

  test "collapsible renders a trigger and hidden content by default" do
    html = render_collapsible()

    assert html =~ ~s(data-slot="collapsible")
    assert html =~ ~s(data-state="closed")

    [trigger] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=collapsible-trigger]")
    assert Floki.attribute(trigger, "aria-expanded") == ["false"]
    assert Floki.attribute(trigger, "aria-controls") == ["faq-content"]

    [content] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=collapsible-content]")
    assert Floki.attribute(content, "hidden") != []
  end

  test "collapsible renders open content when default_open" do
    html = render_collapsible(%{default_open: true})

    assert html =~ ~s(data-state="open")
    [trigger] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=collapsible-trigger]")
    assert Floki.attribute(trigger, "aria-expanded") == ["true"]
    [content] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=collapsible-content]")
    assert Floki.attribute(content, "hidden") == []
  end

  test "clicking the trigger toggles it on the client without a server round trip" do
    html = render_collapsible()
    [trigger] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=collapsible-trigger]")
    [command] = Floki.attribute(trigger, "phx-click")

    refute command =~ "push"
    assert command =~ "aria-expanded"
    assert command =~ "data-state"
    assert command =~ "hidden"
    assert command =~ "faq-content"
  end

  test "a disabled trigger has no click command" do
    html =
      render_collapsible(%{
        trigger: [%{__slot__: :trigger, disabled: true, inner_block: fn _, _ -> "Question" end}]
      })

    [trigger] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=collapsible-trigger]")

    assert Floki.attribute(trigger, "phx-click") == []
    assert Floki.attribute(trigger, "disabled") != []
    assert Floki.attribute(trigger, "data-disabled") == [""]
  end
end
