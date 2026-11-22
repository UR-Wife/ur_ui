defmodule UrUi.RadioGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  defp slot(value, content, disabled \\ nil) do
    %{
      __slot__: :item,
      value: value,
      disabled: disabled,
      inner_block: fn _changed, _argument -> content end
    }
  end

  defp render_radio_group(assigns \\ %{}) do
    defaults = %{
      id: "size",
      item: [
        slot("default", "Default"),
        slot("comfortable", "Comfortable")
      ]
    }

    render_component(&Components.radio_group/1, Map.merge(defaults, Map.new(assigns)))
  end

  test "renders a radiogroup with two radio buttons" do
    html = render_radio_group()

    assert html =~ ~s(role="radiogroup")
    assert html =~ ~s(data-slot="radio-group")
    buttons = Floki.parse_fragment!(html) |> Floki.find("[data-slot=radio-group-item]")
    assert length(buttons) == 2
    assert Floki.attribute(buttons, "type") == ["button", "button"]
    assert Floki.attribute(buttons, "role") == ["radio", "radio"]
  end

  test "selects the first item with roving tabindex" do
    html = render_radio_group()
    buttons = Floki.parse_fragment!(html) |> Floki.find("[data-slot=radio-group-item]")

    assert Floki.attribute(buttons, "aria-checked") == ["true", "false"]
    assert Floki.attribute(buttons, "data-state") == ["checked", "unchecked"]
    assert Floki.attribute(buttons, "tabindex") == ["0", "-1"]
  end

  test "default_value selects a matching item and falls back to the first" do
    html = render_radio_group(%{default_value: "comfortable"})
    buttons = Floki.parse_fragment!(html) |> Floki.find("[data-slot=radio-group-item]")
    assert Floki.attribute(buttons, "aria-checked") == ["false", "true"]

    html = render_radio_group(%{default_value: "missing"})
    buttons = Floki.parse_fragment!(html) |> Floki.find("[data-slot=radio-group-item]")
    assert Floki.attribute(buttons, "aria-checked") == ["true", "false"]
  end

  test "the indicator is hidden on unchecked items" do
    html = render_radio_group()
    indicators = Floki.parse_fragment!(html) |> Floki.find("[data-slot=radio-group-indicator]")

    assert Floki.attribute(Enum.at(indicators, 0), "hidden") == []
    assert Floki.attribute(Enum.at(indicators, 1), "hidden") != []
  end

  test "selecting runs client-side without a server round trip" do
    html = render_radio_group()
    buttons = Floki.parse_fragment!(html) |> Floki.find("[data-slot=radio-group-item]")
    commands = Floki.attribute(buttons, "phx-click")

    assert length(commands) == 2

    for command <- commands do
      refute command =~ "push"
      assert command =~ "aria-checked"
      assert command =~ "tabindex"
      assert command =~ "data-state"
      assert command =~ "radio-group-indicator"
    end
  end

  test "renders hidden radio inputs when name is given" do
    html = render_radio_group(%{name: "size"})
    inputs = Floki.parse_fragment!(html) |> Floki.find("input[type=radio]")

    assert length(inputs) == 2
    assert Floki.attribute(inputs, "name") == ["size", "size"]
    assert Floki.attribute(inputs, "value") == ["default", "comfortable"]
    assert Floki.attribute(inputs, "checked") == ["checked"]
  end

  test "uses the UrUiRadioGroup hook with no inline script" do
    html = render_radio_group()
    [root] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=radio-group]")

    assert Floki.attribute(root, "phx-hook") == ["UrUiRadioGroup"]
    refute html =~ "<script"
    refute html =~ ~r/\son[a-z]+=/
  end

  test "a disabled item is a disabled button with no click command" do
    html =
      render_radio_group(%{
        item: [slot("default", "Default"), slot("comfortable", "Comfortable", true)]
      })

    buttons = Floki.parse_fragment!(html) |> Floki.find("[data-slot=radio-group-item]")
    assert Floki.attribute(Enum.at(buttons, 0), "disabled") == []
    assert Floki.attribute(Enum.at(buttons, 1), "disabled") != []
    assert Floki.attribute(Enum.at(buttons, 1), "phx-click") == []
  end

  test "a disabled group disables every item" do
    html = render_radio_group(%{disabled: true})
    buttons = Floki.parse_fragment!(html) |> Floki.find("[data-slot=radio-group-item]")

    assert Floki.attribute(buttons, "disabled") == ["disabled", "disabled"]
    assert Floki.attribute(buttons, "phx-click") == []
  end

  test "a disabled first item does not take the tab stop" do
    html =
      render_radio_group(%{
        item: [slot("default", "Default", true), slot("comfortable", "Comfortable")]
      })

    buttons = Floki.parse_fragment!(html) |> Floki.find("[data-slot=radio-group-item]")
    assert Floki.attribute(buttons, "aria-checked") == ["false", "true"]
    assert Floki.attribute(buttons, "tabindex") == ["-1", "0"]
  end
end
