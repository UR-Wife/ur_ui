defmodule UrUi.SwitchTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  @base "peer group/switch inline-flex shrink-0 items-center rounded-full border border-transparent shadow-xs transition-all outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 data-[size=default]:h-[1.15rem] data-[size=default]:w-8 data-[size=sm]:h-3.5 data-[size=sm]:w-6 data-[state=checked]:bg-primary data-[state=unchecked]:bg-input dark:data-[state=unchecked]:bg-input/80"

  defp render_switch(assigns), do: render_component(&Components.switch/1, assigns)

  test "switch renders an unchecked button with shadcn's classes" do
    html = render_switch(%{id: "terms"})

    assert html =~ "<button"
    assert html =~ ~s(role="switch")
    assert html =~ ~s(aria-checked="false")
    assert html =~ ~s(data-state="unchecked")
    assert html =~ ~s(data-size="default")
    assert html =~ ~s(data-slot="switch")
    [button] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=switch]")
    assert Floki.attribute(button, "class") == [@base]
    assert html =~ "switch-thumb"
  end

  test "switch renders checked state and toggles on the client" do
    html = render_switch(%{id: "terms", checked: true})
    [button] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=switch]")

    assert html =~ ~s(aria-checked="true")
    assert html =~ ~s(data-state="checked")

    [command] = Floki.attribute(button, "phx-click")
    refute command =~ "push"
    assert command =~ "aria-checked"
    assert command =~ "switch-thumb"
  end

  test "switch renders a hidden input and dispatches change when name is given" do
    html = render_switch(%{id: "terms", name: "terms", checked: true})
    [input] = Floki.parse_fragment!(html) |> Floki.find("input[type=checkbox]")

    assert Floki.attribute(input, "id") == ["terms-input"]
    assert Floki.attribute(input, "name") == ["terms"]
    assert Floki.attribute(input, "checked") != []

    [button] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=switch]")
    [command] = Floki.attribute(button, "phx-click")
    assert command =~ ~s(["dispatch",{"to":"#terms-input","event":"change"}])
  end

  test "switch omits the hidden input without a name" do
    html = render_switch(%{id: "terms"})
    refute html =~ "<input"
  end

  test "switch applies the sm size and global attrs" do
    html = render_switch(%{id: "terms", size: :sm, "aria-label": "Compact"})

    assert html =~ ~s(data-size="sm")
    assert html =~ ~s(aria-label="Compact")
  end

  test "a disabled switch gets no click command" do
    html = render_switch(%{id: "terms", disabled: true})
    [button] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=switch]")

    assert Floki.attribute(button, "phx-click") == []
    assert Floki.attribute(button, "disabled") != []
  end
end
