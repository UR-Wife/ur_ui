defmodule Storybook.UrUi.Progress do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.progress/1
  def render_source, do: :function

  # The progress bar is w-full; a sized wrapper gives it a fixed width, as in
  # the shadcn docs.
  defp sized do
    """
    <div class="w-64">
      <.psb-variation/>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Sixty percent complete",
        template: sized(),
        attributes: %{id: "progress", value: 60, "aria-label": "Progress"}
      },
      %Variation{
        id: :complete,
        description: "Complete",
        template: sized(),
        attributes: %{id: "progress", value: 100, "aria-label": "Progress"}
      },
      %Variation{
        id: :quarter,
        description: "Quarter complete",
        template: sized(),
        attributes: %{id: "progress", value: 25, "aria-label": "Progress"}
      }
    ]
  end
end