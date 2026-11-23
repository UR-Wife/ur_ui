defmodule Storybook.UrUi.ToggleGroup do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.toggle_group/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :single,
        description: "Single selection, outline variant",
        attributes: %{id: "format", type: :single, variant: :outline, default_value: "bold"},
        slots: [
          ~s|<:item value="bold">Bold</:item>|,
          ~s|<:item value="italic">Italic</:item>|,
          ~s|<:item value="underline">Underline</:item>|
        ]
      },
      %Variation{
        id: :multiple,
        description: "Multiple selection",
        attributes: %{
          id: "format-multiple",
          type: :multiple,
          variant: :outline,
          default_value: ["bold", "italic"]
        },
        slots: [
          ~s|<:item value="bold">Bold</:item>|,
          ~s|<:item value="italic">Italic</:item>|,
          ~s|<:item value="underline">Underline</:item>|
        ]
      }
    ]
  end
end
