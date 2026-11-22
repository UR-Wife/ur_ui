defmodule Storybook.UrUi.AspectRatio do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.aspect_ratio/1
  def render_source, do: :function

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
        description: "16/9 ratio",
        template: sized(),
        attributes: %{ratio: "16/9"},
        slots: [~s(<div class="h-full w-full bg-muted"></div>)]
      },
      %Variation{
        id: :square,
        description: "1/1 ratio",
        template: sized(),
        attributes: %{ratio: "1/1"},
        slots: [~s(<div class="h-full w-full bg-muted"></div>)]
      }
    ]
  end
end