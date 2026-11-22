defmodule UrUi.CheckboxTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @component UrUi.Components
  @base "peer size-4 shrink-0 rounded-[4px] border border-input shadow-xs transition-shadow outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 data-[state=checked]:border-primary data-[state=checked]:bg-primary data-[state=checked]:text-primary-foreground dark:bg-input/30 dark:aria-invalid:ring-destructive/40 dark:data-[state=checked]:bg-primary"

  defp assert_checkbox_classes(html, custom \\ nil) do
    expected = [@base, custom] |> Enum.reject(&is_nil/1) |> Enum.join(" ")
    [checkbox] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=checkbox]")
    assert Floki.attribute(checkbox, "class") == [expected]
  end

  defp render_checkbox(assigns) do
    render_component(Function.capture(@component, :checkbox, 1), Map.new(assigns))
  end

  test "checkbox renders an unchecked button with no optional attrs" do
    html = render_checkbox(%{id: "terms"})

    assert html =~ "<button"
    assert html =~ ~s(type="button")
    assert html =~ ~s(role="checkbox")
    assert html =~ ~s(aria-checked="false")
    assert html =~ ~s(data-state="unchecked")
    assert html =~ ~s(value="on")
    assert html =~ ~s(data-slot="checkbox")
    assert_checkbox_classes(html)
    refute html =~ "ur-checkbox"
  end

  test "checkbox hides the indicator while unchecked and shows it when checked" do
    unchecked = render_checkbox(%{id: "terms"})
    [indicator] = Floki.parse_fragment!(unchecked) |> Floki.find("[data-slot=checkbox-indicator]")
    assert Floki.attribute(indicator, "hidden") != []

    checked = render_checkbox(%{id: "terms", checked: true})
    assert checked =~ ~s(aria-checked="true")
    assert checked =~ ~s(data-state="checked")
    [indicator] = Floki.parse_fragment!(checked) |> Floki.find("[data-slot=checkbox-indicator]")
    assert Floki.attribute(indicator, "hidden") == []
    assert checked =~ ~s(<path d="M20 6 9 17l-5-5")
  end

  test "checkbox extends classes and passes global attrs" do
    html =
      render_checkbox(%{
        id: "terms",
        class: "extra",
        name: "terms",
        value: "yes",
        required: true,
        disabled: true,
        "aria-label": "Accept terms",
        "data-testid": "terms-checkbox"
      })

    assert_checkbox_classes(html, "extra")
    assert html =~ ~s(id="terms")
    assert html =~ ~s(aria-required="true")
    assert html =~ ~s(disabled)
    assert html =~ ~s(data-disabled="")
    assert html =~ ~s(aria-label="Accept terms")
    assert html =~ ~s(data-testid="terms-checkbox")
  end

  test "checkbox renders a hidden input for form submission when name is given" do
    html = render_checkbox(%{id: "terms", name: "terms", value: "yes", checked: true})

    [input] = Floki.parse_fragment!(html) |> Floki.find("input[type=checkbox]")
    assert Floki.attribute(input, "id") == ["terms-input"]
    assert Floki.attribute(input, "name") == ["terms"]
    assert Floki.attribute(input, "value") == ["yes"]
    assert Floki.attribute(input, "checked") != []
    assert Floki.attribute(input, "aria-hidden") == ["true"]
    assert Floki.attribute(input, "tabindex") == ["-1"]
  end

  test "checkbox omits the hidden input without a name" do
    html = render_checkbox(%{id: "terms"})

    refute html =~ "<input"
  end

  test "clicking a checkbox toggles it on the client without a server round trip" do
    html = render_checkbox(%{id: "terms"})
    [button] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=checkbox]")
    [command] = Floki.attribute(button, "phx-click")

    refute command =~ "push"
    assert command =~ "aria-checked"
    assert command =~ "data-state"
    assert command =~ "hidden"
    assert command =~ "checkbox-indicator"
    assert command =~ "terms-input"
  end

  test "a disabled checkbox gets no click command" do
    html = render_checkbox(%{id: "terms", disabled: true})
    [button] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=checkbox]")

    assert Floki.attribute(button, "phx-click") == []
    assert Floki.attribute(button, "disabled") != []
  end

  test "checkbox uses the UrUiCheckbox hook to prevent Enter, with no inline script" do
    html = render_checkbox(%{id: "terms"})
    [button] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=checkbox]")

    assert Floki.attribute(button, "phx-hook") == ["UrUiCheckbox"]
    refute html =~ "<script"
    refute html =~ ~r/\son[a-z]+=/
  end
end
