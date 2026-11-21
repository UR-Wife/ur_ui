defmodule UrUi.ButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @component UrUi.Components
  @base "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive"
  @variants %{
    default: "bg-primary text-primary-foreground shadow-xs hover:bg-primary/90",
    destructive:
      "bg-destructive text-white shadow-xs hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60",
    outline:
      "border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground dark:bg-input/30 dark:border-input dark:hover:bg-input/50",
    secondary: "bg-secondary text-secondary-foreground shadow-xs hover:bg-secondary/80",
    ghost: "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50",
    link: "text-primary underline-offset-4 hover:underline"
  }
  @sizes %{
    default: "h-9 px-4 py-2 has-[>svg]:px-3",
    xs:
      "h-6 gap-1.5 rounded-md px-2 text-xs has-[>svg]:px-1.5 [&_svg:not([class*='size-'])]:size-3",
    sm: "h-8 rounded-md gap-1.5 px-3 has-[>svg]:px-2.5",
    lg: "h-10 rounded-md px-6 has-[>svg]:px-4",
    icon: "size-9",
    icon_xs: "size-6 rounded-md [&_svg:not([class*='size-'])]:size-3",
    icon_sm: "size-8",
    icon_lg: "size-10"
  }

  defp inner(content \\ "Click") do
    %{__slot__: :inner_block, inner_block: fn _changed, _argument -> content end}
  end

  defp render_button(assigns) do
    assigns
    |> Map.new()
    |> Map.put_new(:inner_block, inner())
    |> then(&render_component(Function.capture(@component, :button, 1), &1))
  end

  defp assert_classes(html, variant \\ :default, size \\ :default, custom \\ nil) do
    expected =
      [@base, @variants[variant], @sizes[size], custom]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")

    [button] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=button]")
    assert Floki.attribute(button, "class") == [expected]
  end

  describe "button variants" do
    test "variant :default renders the primary button classes" do
      html = render_button(%{variant: :default})
      assert_classes(html)
      assert html =~ ~s(data-variant="default")
      assert html =~ "Click"
    end

    test "variant :destructive renders destructive button classes" do
      html = render_button(%{variant: :destructive})
      assert_classes(html, :destructive)
      assert html =~ ~s(data-variant="destructive")
    end

    test "variant :outline renders outline button classes" do
      html = render_button(%{variant: :outline})
      assert_classes(html, :outline)
      assert html =~ ~s(data-variant="outline")
    end

    test "variant :secondary renders secondary button classes" do
      html = render_button(%{variant: :secondary})
      assert_classes(html, :secondary)
      assert html =~ ~s(data-variant="secondary")
    end

    test "variant :ghost renders ghost button classes" do
      html = render_button(%{variant: :ghost})
      assert_classes(html, :ghost)
      assert html =~ ~s(data-variant="ghost")
    end

    test "variant :link renders link button classes" do
      html = render_button(%{variant: :link})
      assert_classes(html, :link)
      assert html =~ ~s(data-variant="link")
    end
  end

  describe "button sizes" do
    test "size :default renders default size classes" do
      html = render_button(%{size: :default})
      assert_classes(html)
      assert html =~ ~s(data-size="default")
    end

    test "size :xs renders xs size classes" do
      html = render_button(%{size: :xs})
      assert_classes(html, :default, :xs)
      assert html =~ ~s(data-size="xs")
    end

    test "size :sm renders sm size classes" do
      html = render_button(%{size: :sm})
      assert_classes(html, :default, :sm)
      assert html =~ ~s(data-size="sm")
    end

    test "size :lg renders lg size classes" do
      html = render_button(%{size: :lg})
      assert_classes(html, :default, :lg)
      assert html =~ ~s(data-size="lg")
    end

    test "size :icon renders icon size classes" do
      html = render_button(%{size: :icon})
      assert_classes(html, :default, :icon)
      assert html =~ ~s(data-size="icon")
    end

    test "size :icon_xs renders icon_xs size classes" do
      html = render_button(%{size: :icon_xs})
      assert_classes(html, :default, :icon_xs)
      assert html =~ ~s(data-size="icon_xs")
    end

    test "size :icon_sm renders icon_sm size classes" do
      html = render_button(%{size: :icon_sm})
      assert_classes(html, :default, :icon_sm)
      assert html =~ ~s(data-size="icon_sm")
    end

    test "size :icon_lg renders icon_lg size classes" do
      html = render_button(%{size: :icon_lg})
      assert_classes(html, :default, :icon_lg)
      assert html =~ ~s(data-size="icon_lg")
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
      assert_classes(html, :default, :default, "mt-4")
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
