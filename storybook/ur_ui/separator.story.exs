defmodule Storybook.UrUi.Separator do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.separator/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :horizontal,
        description: "Horizontal divider (decorative)",
        attributes: %{orientation: :horizontal}
      },
      %Variation{
        id: :vertical,
        description: "Vertical divider (decorative)",
        attributes: %{orientation: :vertical}
      },
      %Variation{
        id: :semantic,
        description: "Semantic separator (role separator)",
        attributes: %{decorative: false}
      },
      %Variation{
        id: :custom_class,
        description: "class extends the base classes",
        attributes: %{class: "psb:opacity-80"}
      }
    ]
  end
end
