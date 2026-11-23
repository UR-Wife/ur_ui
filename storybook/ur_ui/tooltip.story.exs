defmodule Storybook.UrUi.Tooltip do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.tooltip/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :bottom,
        description: "Tooltip positioned below the trigger with a small offset",
        attributes: %{id: "tooltip-bottom"},
        slots: [
          "<UrUi.Components.tooltip_trigger>Hover</UrUi.Components.tooltip_trigger><UrUi.Components.tooltip_content id=\"tooltip-bottom-content\" side={:bottom} side_offset={4}>Information</UrUi.Components.tooltip_content>"
        ]
      },
      %Variation{
        id: :default,
        description: "Tooltip shown on the top, revealed instantly",
        attributes: %{id: "tooltip-default"},
        slots: [
          "<UrUi.Components.tooltip_trigger>Hover</UrUi.Components.tooltip_trigger><UrUi.Components.tooltip_content id=\"tooltip-default-content\" side={:top}>Add to library</UrUi.Components.tooltip_content>"
        ]
      },
      %Variation{
        id: :delayed,
        description: "Tooltip revealed after a short hover delay",
        attributes: %{id: "tooltip-delayed", delay_duration: 100},
        slots: [
          "<UrUi.Components.tooltip_trigger>Hover</UrUi.Components.tooltip_trigger><UrUi.Components.tooltip_content id=\"tooltip-delayed-content\" side={:top}>Add to library</UrUi.Components.tooltip_content>"
        ]
      }
    ]
  end
end
