defmodule Storybook.UrUi.Label do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.label/1
  def render_source, do: :function

  def variations do
    [
      %Variation{id: :default, slots: ["Email"]},
      %Variation{id: :with_for, attributes: %{for: "email"}, slots: ["Email"]},
      %Variation{
        id: :custom_class,
        description: "class extends the base classes",
        attributes: %{class: "psb:opacity-80"},
        slots: ["With extra class"]
      }
    ]
  end
end
