defmodule Storybook.UrUi.Alert do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.alert/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default status alert",
        attributes: %{variant: :default},
        slots: [
          "<UrUi.Components.alert_title>Update available</UrUi.Components.alert_title>",
          "<UrUi.Components.alert_description>A new version is ready to install.</UrUi.Components.alert_description>"
        ]
      },
      %Variation{
        id: :destructive,
        description: "Destructive or failed action",
        attributes: %{variant: :destructive},
        slots: [
          "<UrUi.Components.alert_title>Unable to delete workspace</UrUi.Components.alert_title>",
          "<UrUi.Components.alert_description>Check your permissions and try again.</UrUi.Components.alert_description>"
        ]
      },
      %Variation{
        id: :with_icon,
        description: "Optional icon occupies the leading grid column",
        slots: [
          "<span data-slot=\"alert-icon\" aria-hidden=\"true\">!</span>",
          "<UrUi.Components.alert_title>Heads up</UrUi.Components.alert_title>",
          "<UrUi.Components.alert_description>Icons are optional and use the current text colour.</UrUi.Components.alert_description>"
        ]
      },
      %Variation{
        id: :title_only,
        description: "Description is optional",
        slots: ["<UrUi.Components.alert_title>Changes saved.</UrUi.Components.alert_title>"]
      }
    ]
  end
end
