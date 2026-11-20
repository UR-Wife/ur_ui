defmodule Storybook.UrUi.Skeleton do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.skeleton/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        description: "Placeholder block (size it via class)"
      },
      %Variation{
        id: :custom_class,
        description: "class extends the base classes",
        attributes: %{class: "psb:opacity-80"}
      }
    ]
  end
end
