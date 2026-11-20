defmodule UrUi.ButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # Contract locked by tests BEFORE the component exists (TDD).
  # Rendering goes through render_component/2 per spec. Slot entries are
  # built the way Phoenix.LiveView.TagEngine builds them.
  @component UrUi.Components

  defp inner(content \\ "Click") do
    %{__slot__: :inner_block, inner_block: fn _changed, _argument -> content end}
  end

  defp render_button(assigns) do
    assigns
    |> Map.new()
    |> Map.put_new(:inner_block, inner())
    |> then(&render_component(Function.capture(@component, :button, 1), &1))
  end

  describe "button variants" do
    test "variant :default renders the primary button classes" do
      html = render_button(%{variant: :default})
      assert html =~ "ur-btn"
      assert html =~ ~s(data-variant="default")
      assert html =~ "ur-btn--default"
      assert html =~ "Click"
    end

    test "variant :destructive renders destructive button classes" do
      html = render_button(%{variant: :destructive})
      assert html =~ ~s(data-variant="destructive")
      assert html =~ "ur-btn--destructive"
    end

    test "variant :outline renders outline button classes" do
      html = render_button(%{variant: :outline})
      assert html =~ ~s(data-variant="outline")
      assert html =~ "ur-btn--outline"
    end

    test "variant :secondary renders secondary button classes" do
      html = render_button(%{variant: :secondary})
      assert html =~ ~s(data-variant="secondary")
      assert html =~ "ur-btn--secondary"
    end

    test "variant :ghost renders ghost button classes" do
      html = render_button(%{variant: :ghost})
      assert html =~ ~s(data-variant="ghost")
      assert html =~ "ur-btn--ghost"
    end

    test "variant :link renders link button classes" do
      html = render_button(%{variant: :link})
      assert html =~ ~s(data-variant="link")
      assert html =~ "ur-btn--link"
    end
  end

  describe "button sizes" do
    test "size :default renders default size classes" do
      html = render_button(%{size: :default})
      assert html =~ ~s(data-size="default")
      assert html =~ "ur-btn--size-default"
    end

    test "size :xs renders xs size classes" do
      html = render_button(%{size: :xs})
      assert html =~ ~s(data-size="xs")
      assert html =~ "ur-btn--size-xs"
    end

    test "size :sm renders sm size classes" do
      html = render_button(%{size: :sm})
      assert html =~ ~s(data-size="sm")
      assert html =~ "ur-btn--size-sm"
    end

    test "size :lg renders lg size classes" do
      html = render_button(%{size: :lg})
      assert html =~ ~s(data-size="lg")
      assert html =~ "ur-btn--size-lg"
    end

    test "size :icon renders icon size classes" do
      html = render_button(%{size: :icon})
      assert html =~ ~s(data-size="icon")
      assert html =~ "ur-btn--size-icon"
    end

    test "size :icon_xs renders icon_xs size classes" do
      html = render_button(%{size: :icon_xs})
      assert html =~ ~s(data-size="icon_xs")
      assert html =~ "ur-btn--size-icon_xs"
    end

    test "size :icon_sm renders icon_sm size classes" do
      html = render_button(%{size: :icon_sm})
      assert html =~ ~s(data-size="icon_sm")
      assert html =~ "ur-btn--size-icon_sm"
    end

    test "size :icon_lg renders icon_lg size classes" do
      html = render_button(%{size: :icon_lg})
      assert html =~ ~s(data-size="icon_lg")
      assert html =~ "ur-btn--size-icon_lg"
    end
  end

  describe "button behaviour" do
    test "renders a <button> with type=button by default" do
      html = render_button(%{})
      assert html =~ "<button"
      assert html =~ ~s(type="button")
    end

    test "renders an <a> when href is given (shadcn asChild port)" do
      html = render_button(%{href: "/save"})
      assert html =~ "<a"
      assert html =~ ~s(href="/save")
      refute html =~ "<button"
    end

    test "disabled renders the disabled attribute on <button>" do
      html = render_button(%{disabled: true})
      assert html =~ "disabled"
    end

    test "type attribute is respected" do
      html = render_button(%{type: "submit"})
      assert html =~ ~s(type="submit")
    end

    test "custom class is appended to base classes" do
      html = render_button(%{class: "mt-4"})
      assert html =~ "ur-btn"
      assert html =~ "mt-4"
    end

    test "global attributes pass through" do
      html = render_button(%{id: "save", "aria-label": "Save"})
      assert html =~ ~s(id="save")
      assert html =~ ~s(aria-label="Save")
    end

    test "renders with only inner_block; missing optional attrs never crash" do
      html = render_button(%{})
      assert html =~ "Click"
    end
  end
end