defmodule UrUi.AccordionTest do
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

  defp render_accordion(assigns \\ %{}) do
    defaults = %{
      id: "faq",
      trigger: [
        slot(:trigger, "billing", "Billing"),
        slot(:trigger, "team", "Team")
      ],
      content: [
        slot(:content, "billing", "Billing panel"),
        slot(:content, "team", "Team panel")
      ]
    }

    render_component(
      Function.capture(@component, :accordion, 1),
      Map.merge(defaults, Map.new(assigns))
    )
  end

  test "accordion renders closed items with matching ARIA relationships" do
    document = render_accordion() |> Floki.parse_fragment!()
    buttons = Floki.find(document, "[data-slot=accordion-trigger]")
    panels = Floki.find(document, "[data-slot=accordion-content]")

    assert length(Floki.find(document, "[data-slot=accordion-item]")) == 2
    assert length(Floki.find(document, "h3")) == 2
    assert Floki.attribute(buttons, "type") == ["button", "button"]
    assert Floki.attribute(buttons, "id") == ["faq-trigger-0", "faq-trigger-1"]
    assert Floki.attribute(buttons, "aria-expanded") == ["false", "false"]
    assert Floki.attribute(buttons, "aria-controls") == ["faq-panel-0", "faq-panel-1"]
    assert Floki.attribute(buttons, "data-state") == ["closed", "closed"]

    assert Floki.attribute(panels, "id") == ["faq-panel-0", "faq-panel-1"]
    assert Floki.attribute(panels, "role") == ["region", "region"]
    assert Floki.attribute(panels, "aria-labelledby") == ["faq-trigger-0", "faq-trigger-1"]
    assert Floki.attribute(panels, "data-state") == ["closed", "closed"]
    assert Floki.attribute(Enum.at(panels, 0), "hidden") == ["hidden"]
    assert Floki.attribute(Enum.at(panels, 1), "hidden") == ["hidden"]
    assert String.trim(Floki.text(Enum.at(panels, 0))) == "Billing panel"
    assert String.trim(Floki.text(Enum.at(panels, 1))) == "Team panel"
  end

  test "accordion pairs triggers and contents by value" do
    html =
      render_accordion(%{
        content: [
          slot(:content, "team", "Team panel"),
          slot(:content, "billing", "Billing panel")
        ]
      })

    panels = Floki.find(Floki.parse_fragment!(html), "[data-slot=accordion-content]")

    assert String.trim(Floki.text(Enum.at(panels, 0))) == "Billing panel"
    assert String.trim(Floki.text(Enum.at(panels, 1))) == "Team panel"
  end

  test "accordion opens the default item" do
    document = render_accordion(%{default_value: "team"}) |> Floki.parse_fragment!()
    buttons = Floki.find(document, "[data-slot=accordion-trigger]")
    panels = Floki.find(document, "[data-slot=accordion-content]")

    assert Floki.attribute(buttons, "aria-expanded") == ["false", "true"]
    assert Floki.attribute(buttons, "data-state") == ["closed", "open"]
    assert Floki.attribute(Enum.at(panels, 0), "hidden") == ["hidden"]
    assert Floki.attribute(Enum.at(panels, 1), "hidden") == []
    assert Floki.attribute(Enum.at(panels, 1), "data-state") == ["open"]
  end

  test "accordion opens every listed default value" do
    document =
      render_accordion(%{type: :multiple, default_value: ["billing", "team"]})
      |> Floki.parse_fragment!()

    buttons = Floki.find(document, "[data-slot=accordion-trigger]")

    assert Floki.attribute(buttons, "aria-expanded") == ["true", "true"]
    assert Floki.attribute(buttons, "data-state") == ["open", "open"]
  end

  test "accordion toggles its item with client-only JS commands" do
    document = render_accordion() |> Floki.parse_fragment!()

    [first, second] =
      Floki.find(document, "[data-slot=accordion-trigger]") |> Floki.attribute("phx-click")

    for {command, index} <- Enum.with_index([first, second]) do
      assert command =~ "toggle_attr"
      assert command =~ "aria-expanded"
      assert command =~ "data-state"
      assert command =~ "faq-trigger-#{index}"
      assert command =~ "faq-panel-#{index}"
      assert command =~ "hidden"
      refute command =~ "push"
    end
  end

  test "single accordion force-closes the other items in its JS command" do
    document = render_accordion() |> Floki.parse_fragment!()

    [first, _second] =
      Floki.find(document, "[data-slot=accordion-trigger]") |> Floki.attribute("phx-click")

    assert first =~ "faq-trigger-1"
    assert first =~ "faq-panel-1"
    assert first =~ "set_attr"
  end

  test "multiple accordion only toggles its own item" do
    document = render_accordion(%{type: :multiple}) |> Floki.parse_fragment!()

    [first, _second] =
      Floki.find(document, "[data-slot=accordion-trigger]") |> Floki.attribute("phx-click")

    refute first =~ "faq-trigger-1"
    refute first =~ "faq-panel-1"
    refute first =~ "set_attr"
  end

  test "disabled trigger renders disabled and gets no click command" do
    html =
      render_accordion(%{
        trigger: [Map.put(slot(:trigger, "billing", "Billing"), :disabled, true)],
        content: [slot(:content, "billing", "Billing panel")]
      })

    document = Floki.parse_fragment!(html)
    [button] = Floki.find(document, "[data-slot=accordion-trigger]")

    assert Floki.attribute(button, "disabled") == ["disabled"]
    assert Floki.attribute(button, "phx-click") == []
  end

  test "accordion extends classes and passes global attrs through" do
    html = render_accordion(%{class: "extra", "aria-label": "FAQ"})

    assert html =~ "ur-accordion extra"
    assert html =~ ~s(aria-label="FAQ")
  end

  test "accordion renders with no optional attrs and empty slots" do
    html =
      render_component(Function.capture(@component, :accordion, 1), %{
        id: "empty",
        trigger: [],
        content: []
      })

    assert html =~ "ur-accordion"
    assert html =~ ~s(data-slot="accordion")
  end

  test "accordion renders an empty panel when no content matches the trigger value" do
    html =
      render_accordion(%{
        trigger: [slot(:trigger, "billing", "Billing")],
        content: [slot(:content, "other", "Orphan panel")]
      })

    assert html =~ ~s(id="faq-panel-0")
    refute html =~ "Orphan panel"
  end
end
