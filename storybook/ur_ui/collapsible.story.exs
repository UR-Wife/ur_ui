defmodule Storybook.UrUi.Collapsible do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.collapsible/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        description: "Closed by default",
        attributes: %{id: "collapsible"},
        slots: [
          "<:trigger>Can I use this in my project?</:trigger>",
          "<:content>Yes. Free to use for personal and commercial projects.</:content>"
        ]
      },
      %Variation{
        id: :default_open,
        description: "Open by default",
        attributes: %{id: "collapsible-open", default_open: true},
        slots: [
          "<:trigger>Can I use this in my project?</:trigger>",
          "<:content>Yes. Free to use for personal and commercial projects.</:content>"
        ]
      }
    ]
  end
end
