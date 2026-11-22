defmodule Storybook.UrUi.Empty do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.empty/1
  def render_source, do: :function

  defp sized do
    """
    <div class="w-80">
      <.psb-variation/>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Title, description and icon",
        template: sized(),
        slots: [
          "<UrUi.Components.empty_media variant={:icon}><span>UR</span></UrUi.Components.empty_media><UrUi.Components.empty_title>No results</UrUi.Components.empty_title><UrUi.Components.empty_description>Try adjusting your search.</UrUi.Components.empty_description>"
        ]
      }
    ]
  end
end
