defmodule Storybook.UrUi.Kbd do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.kbd/1
  def render_source, do: :function

  def variations do
    [
      %Variation{id: :default, slots: ["K"]},
      %Variation{
        id: :custom_class,
        description: "class extends the base classes",
        attributes: %{class: "tracking-wide"},
        slots: ["K"]
      }
    ]
  end
end
