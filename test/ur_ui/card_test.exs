defmodule UrUi.CardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @component UrUi.Components
  @classes %{
    card: "bg-card text-card-foreground flex flex-col gap-6 rounded-xl border py-6 shadow-sm",
    card_header:
      "@container/card-header grid auto-rows-min grid-rows-[auto_auto] items-start gap-2 px-6 has-data-[slot=card-action]:grid-cols-[1fr_auto] [.border-b]:pb-6",
    card_title: "leading-none font-semibold",
    card_description: "text-muted-foreground text-sm",
    card_action: "col-start-2 row-span-2 row-start-1 self-start justify-self-end",
    card_content: "px-6",
    card_footer: "flex items-center px-6 [.border-t]:pt-6"
  }

  defp inner(content) do
    %{__slot__: :inner_block, inner_block: fn _changed, _argument -> content end}
  end

  defp render_part(name, assigns, content) do
    assigns = assigns |> Map.new() |> Map.put_new(:inner_block, [inner(content)])
    render_component(Function.capture(@component, name, 1), assigns)
  end

  defp assert_classes(html, name, custom \\ nil) do
    slot = name |> Atom.to_string() |> String.replace("_", "-")
    expected = [@classes[name], custom] |> Enum.reject(&is_nil/1) |> Enum.join(" ")
    [part] = Floki.parse_fragment!(html) |> Floki.find("[data-slot='#{slot}']")
    assert Floki.attribute(part, "class") == [expected]
  end

  test "card renders the default surface without optional attrs" do
    html = render_part(:card, %{}, "Card body")

    assert_classes(html, :card)
    assert html =~ "Card body"
  end

  for name <- [
        :card_header,
        :card_title,
        :card_description,
        :card_action,
        :card_content,
        :card_footer
      ] do
    test "#{name} renders its shadcn slot" do
      name = unquote(name)
      slot = name |> Atom.to_string() |> String.replace("_", "-")
      html = render_part(name, %{}, slot)

      assert_classes(html, name)
      assert html =~ slot
    end
  end

  test "card parts extend classes and pass global attrs through" do
    html =
      render_part(
        :card_content,
        %{class: "extra", id: "details", "aria-label": "Details"},
        "Content"
      )

    assert_classes(html, :card_content, "extra")
    assert html =~ ~s(id="details")
    assert html =~ ~s(aria-label="Details")
  end

  test "card root accepts an empty optional inner block" do
    html = render_component(Function.capture(@component, :card, 1), %{inner_block: []})

    assert html =~ ~s(data-slot="card")
  end
end
