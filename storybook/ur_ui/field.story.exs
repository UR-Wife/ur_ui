defmodule Storybook.UrUi.Field do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.field/1
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
        description: "Label, control, description and error",
        template: sized(),
        slots: [
          "<UrUi.Components.field_content><UrUi.Components.field_title>Email</UrUi.Components.field_title><UrUi.Components.field_description>We will not share your address.</UrUi.Components.field_description><UrUi.Components.input id=\"email\" name=\"email\" placeholder=\"you@example.com\" /></UrUi.Components.field_content>"
        ]
      }
    ]
  end
end
