defmodule Storybook.UrUi.Card do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.card/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        description: "Header, title, description and content",
        attributes: %{class: "psb:max-w-md"},
        slots: [
          "<UrUi.Components.card_header><UrUi.Components.card_title>Team members</UrUi.Components.card_title><UrUi.Components.card_description>Manage your project team.</UrUi.Components.card_description></UrUi.Components.card_header>",
          "<UrUi.Components.card_content>Invite and manage collaborators.</UrUi.Components.card_content>"
        ]
      },
      %Variation{
        id: :with_action,
        description: "Header with a trailing card action",
        attributes: %{class: "psb:max-w-md"},
        slots: [
          "<UrUi.Components.card_header><UrUi.Components.card_title>Notifications</UrUi.Components.card_title><UrUi.Components.card_description>Choose what you receive.</UrUi.Components.card_description><UrUi.Components.card_action><UrUi.Components.button variant={:outline} size={:sm}>Edit</UrUi.Components.button></UrUi.Components.card_action></UrUi.Components.card_header>",
          "<UrUi.Components.card_content>Email notifications are enabled.</UrUi.Components.card_content>"
        ]
      },
      %Variation{
        id: :with_footer,
        description: "Content and footer actions",
        attributes: %{class: "psb:max-w-md"},
        slots: [
          "<UrUi.Components.card_header><UrUi.Components.card_title>Confirm invitation</UrUi.Components.card_title></UrUi.Components.card_header>",
          "<UrUi.Components.card_content>Accept the invitation to join the workspace.</UrUi.Components.card_content>",
          "<UrUi.Components.card_footer><UrUi.Components.button>Accept</UrUi.Components.button><UrUi.Components.button variant={:ghost}>Decline</UrUi.Components.button></UrUi.Components.card_footer>"
        ]
      },
      %Variation{
        id: :content_only,
        description: "Every part is optional",
        slots: ["<UrUi.Components.card_content>A minimal card.</UrUi.Components.card_content>"]
      }
    ]
  end
end
