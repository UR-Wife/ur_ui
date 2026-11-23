defmodule Storybook.UrUi.Slider do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.slider/1
  def render_source, do: :function

  # Mirrors the shadcn docs slider demo. The weight is unclear; sizing is via
  # the wrapper, not the component. The thumb is named with aria-label for
  # assistive tech.
  defp sized do
    """
    <div class="w-64">
      <.psb-variation/>
    </div>
    """
  end

  defp vertical do
    """
    <div class="h-44">
      <.psb-variation/>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Fifty percent",
        template: sized(),
        attributes: %{id: "slider-default", "aria-label": "Volume"}
      },
      %Variation{
        id: :vertical,
        description: "Vertical orientation",
        template: vertical(),
        attributes: %{id: "slider-vertical", orientation: :vertical, "aria-label": "Volume"}
      },
      %Variation{
        id: :step,
        description: "Range not divisible by step",
        template: sized(),
        attributes: %{id: "slider-step", default_value: 0, min: 0, max: 100, step: 3, "aria-label": "Volume"}
      },
      %Variation{
        id: :disabled,
        description: "Disabled",
        template: sized(),
        attributes: %{id: "slider-disabled", disabled: true, "aria-label": "Volume"}
      }
    ]
  end
end
