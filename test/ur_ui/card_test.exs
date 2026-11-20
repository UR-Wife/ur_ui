defmodule UrUi.CardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @component UrUi.Components

  defp inner(content) do
    %{__slot__: :inner_block, inner_block: fn _changed, _argument -> content end}
  end

  defp render_part(name, assigns, content) do
    assigns = assigns |> Map.new() |> Map.put_new(:inner_block, [inner(content)])
    render_component(Function.capture(@component, name, 1), assigns)
  end

  test "card renders the default surface without optional attrs" do
    html = render_part(:card, %{}, "Card body")

    assert html =~ ~s(data-slot="card")
    assert html =~ "ur-card"
    assert html =~ "Card body"
  end

  for {name, slot} <- [
        {:card_header, "card-header"},
        {:card_title, "card-title"},
        {:card_description, "card-description"},
        {:card_action, "card-action"},
        {:card_content, "card-content"},
        {:card_footer, "card-footer"}
      ] do
    test "#{name} renders its shadcn slot" do
      html = render_part(unquote(name), %{}, unquote(slot))

      assert html =~ ~s(data-slot="#{unquote(slot)}")
      assert html =~ "ur-card__#{String.replace(unquote(slot), "card-", "")}"
      assert html =~ unquote(slot)
    end
  end

  test "card parts extend classes and pass global attrs through" do
    html =
      render_part(
        :card_content,
        %{class: "extra", id: "details", "aria-label": "Details"},
        "Content"
      )

    assert html =~ "ur-card__content"
    assert html =~ "extra"
    assert html =~ ~s(id="details")
    assert html =~ ~s(aria-label="Details")
  end

  test "card root accepts an empty optional inner block" do
    html = render_component(Function.capture(@component, :card, 1), %{inner_block: []})

    assert html =~ ~s(data-slot="card")
  end
end
