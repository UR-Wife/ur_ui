defmodule Storybook.UrUi.Badge do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.badge/1
  def render_source, do: :function

  def variations do
    [
      %VariationGroup{
        id: :variants,
        description: "All variants",
        variations: [
          %Variation{id: :default, attributes: %{variant: :default}, slots: ["Default"]},
          %Variation{id: :secondary, attributes: %{variant: :secondary}, slots: ["Secondary"]},
          %Variation{id: :destructive, attributes: %{variant: :destructive}, slots: ["Destructive"]},
          %Variation{id: :outline, attributes: %{variant: :outline}, slots: ["Outline"]},
          %Variation{id: :ghost, attributes: %{variant: :ghost}, slots: ["Ghost"]},
          %Variation{id: :link, attributes: %{variant: :link}, slots: ["Link"]}
        ]
      },
      %Variation{
        id: :custom_class,
        description: "class extends the base classes",
        attributes: %{class: "psb:opacity-80"},
        slots: ["With extra class"]
      }
    ]
  end
end
