defmodule Storybook.UrUi.RadioGroup do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.radio_group/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        description: "Two options, first selected",
        attributes: %{id: "size"},
        slots: [
          ~s|<:item value="default">Default</:item>|,
          ~s|<:item value="comfortable">Comfortable</:item>|
        ]
      },
      %Variation{
        id: :default_value,
        description: "default_value selects the second option",
        attributes: %{id: "size-value", default_value: "comfortable"},
        slots: [
          ~s|<:item value="compact">Compact</:item>|,
          ~s|<:item value="comfortable">Comfortable</:item>|
        ]
      },
      %Variation{
        id: :disabled,
        description: "A disabled option stays unselectable",
        attributes: %{id: "size-disabled"},
        slots: [
          ~s|<:item value="default">Default</:item>|,
          ~s|<:item value="comfortable" disabled>Comfortable</:item>|
        ]
      }
    ]
  end
end