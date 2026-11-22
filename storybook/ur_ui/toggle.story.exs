defmodule Storybook.UrUi.Toggle do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.toggle/1
  def render_source, do: :function

  def variations do
    [
      %Variation{id: :default, slots: ["Bold"]},
      %Variation{id: :pressed, attributes: %{pressed: true}, slots: ["Italic"]},
      %Variation{id: :outline, attributes: %{variant: :outline}, slots: ["Underline"]},
      %Variation{id: :disabled, attributes: %{disabled: true}, slots: ["Disabled"]}
    ]
  end
end
