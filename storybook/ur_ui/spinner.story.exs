defmodule Storybook.UrUi.Spinner do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.spinner/1
  def render_source, do: :function

  def variations do
    [
      %Variation{id: :default},
      %Variation{
        id: :custom_class,
        description: "class sizes the spinner up",
        attributes: %{class: "size-8"}
      }
    ]
  end
end
