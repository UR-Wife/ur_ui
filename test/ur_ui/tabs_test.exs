defmodule UrUi.TabsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @component UrUi.Components

  defp slot(name, value, content) do
    %{
      __slot__: name,
      value: value,
      inner_block: fn _changed, _argument -> content end
    }
  end

  defp render_tabs(assigns \\ %{}) do
    defaults = %{
      id: "account-tabs",
      trigger: [
        slot(:trigger, "general", "General"),
        slot(:trigger, "security", "Security")
      ],
      content: [
        slot(:content, "general", "General panel"),
        slot(:content, "security", "Security panel")
      ]
    }

    render_component(
      Function.capture(@component, :tabs, 1),
      Map.merge(defaults, Map.new(assigns))
    )
  end

  test "tabs selects the first tab and exposes matching ARIA relationships" do
    document = render_tabs() |> Floki.parse_fragment!()
    triggers = Floki.find(document, "[role=tab]")
    panels = Floki.find(document, "[role=tabpanel]")

    assert length(Floki.find(document, "[role=tablist]")) == 1
    assert length(triggers) == 2
    assert Floki.attribute(triggers, "aria-selected") == ["true", "false"]
    assert Floki.attribute(triggers, "aria-controls") == [
             "account-tabs-panel-0",
             "account-tabs-panel-1"
           ]

    assert Floki.attribute(panels, "id") == [
             "account-tabs-panel-0",
             "account-tabs-panel-1"
           ]

    assert Floki.attribute(panels, "aria-labelledby") == [
             "account-tabs-trigger-0",
             "account-tabs-trigger-1"
           ]

    assert Floki.attribute(panels, "aria-hidden") == ["false", "true"]
    assert Floki.attribute(Enum.at(panels, 0), "hidden") == []
    assert Floki.attribute(Enum.at(panels, 1), "hidden") == ["hidden"]
  end

  test "tabs uses native radio arrow-key behavior with client-only JS selection commands" do
    document = render_tabs() |> Floki.parse_fragment!()
    triggers = Floki.find(document, "[role=tab]")
    labels = Floki.find(document, "label")

    assert Floki.attribute(triggers, "type") == ["radio", "radio"]
    assert Floki.attribute(triggers, "name") == ["account-tabs-values", "account-tabs-values"]
    assert Floki.attribute(triggers, "tabindex") == ["0", "-1"]
    assert Floki.attribute(labels, "for") == Floki.attribute(triggers, "id")
    assert Floki.attribute(triggers, "aria-labelledby") == Floki.attribute(labels, "id")

    commands = Floki.attribute(triggers, "phx-change")
    assert length(commands) == 2

    for command <- commands do
      assert command =~ "set_attr"
      assert command =~ "remove_attr"
      assert command =~ "aria-selected"
      assert command =~ "aria-hidden"
      assert command =~ "tabindex"
      assert command =~ "hidden"
    end
  end

  test "tabs keeps the trigger surfaces data-state in sync with client-only JS commands" do
    document = render_tabs() |> Floki.parse_fragment!()
    [first, second] = Floki.find(document, "[role=tab]") |> Floki.attribute("phx-change")

    for command <- [first, second] do
      assert command =~ "account-tabs-trigger-wrap-0"
      assert command =~ "account-tabs-trigger-wrap-1"
      assert command =~ "data-state"
      refute command =~ "push"
    end
  end

  test "tabs extends classes and passes global attrs through" do
    html = render_tabs(%{class: "extra", "aria-label": "Account settings"})

    assert html =~ "ur-tabs extra"
    assert html =~ ~s(aria-label="Account settings")
  end

  test "tabs falls back to the first tab when default_value matches no trigger" do
    document = render_tabs(%{default_value: "missing"}) |> Floki.parse_fragment!()
    triggers = Floki.find(document, "[role=tab]")

    assert Floki.attribute(triggers, "aria-selected") == ["true", "false"]
  end

  test "tabs renders disabled triggers as disabled radios" do
    html =
      render_tabs(%{
        trigger: [
          Map.put(slot(:trigger, "general", "General"), :disabled, true),
          slot(:trigger, "security", "Security")
        ]
      })

    document = Floki.parse_fragment!(html)
    [first, second] = Floki.find(document, "[role=tab]")

    assert Floki.attribute(first, "disabled") == ["disabled"]
    assert Floki.attribute(second, "disabled") == []
  end
end
