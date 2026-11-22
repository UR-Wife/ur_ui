defmodule Storybook.UrUi.Avatar do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.avatar/1
  def render_source, do: :function

  def variations do
    [
      %VariationGroup{
        id: :sizes,
        description: "All sizes with fallback",
        variations: [
          %Variation{
            id: :default,
            attributes: %{size: :default},
            slots: ["<UrUi.Components.avatar_fallback>AB</UrUi.Components.avatar_fallback>"]
          },
          %Variation{
            id: :sm,
            attributes: %{size: :sm},
            slots: ["<UrUi.Components.avatar_fallback>AB</UrUi.Components.avatar_fallback>"]
          },
          %Variation{
            id: :lg,
            attributes: %{size: :lg},
            slots: ["<UrUi.Components.avatar_fallback>AB</UrUi.Components.avatar_fallback>"]
          }
        ]
      },
      %Variation{
        id: :with_image,
        description: "Image with fallback behind it",
        attributes: %{size: :default},
        slots: [
          ~s(<UrUi.Components.avatar_image id="avatar-with-image-photo" src="/ur_ui_logo.svg" alt="UR" />),
          "<UrUi.Components.avatar_fallback>UR</UrUi.Components.avatar_fallback>"
        ]
      },
      %Variation{
        id: :with_badge,
        description: "Fallback with a status badge",
        attributes: %{size: :lg},
        slots: [
          "<UrUi.Components.avatar_fallback>AB</UrUi.Components.avatar_fallback>",
          "<UrUi.Components.avatar_badge>+</UrUi.Components.avatar_badge>"
        ]
      }
    ]
  end
end
