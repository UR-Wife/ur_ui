defmodule Storybook.UrUi.AvatarGroup do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.avatar_group/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :group,
        description: "Overlapping avatars with a +N count bubble",
        slots: [
          ~s(<UrUi.Components.avatar size={:sm}><UrUi.Components.avatar_fallback>AB</UrUi.Components.avatar_fallback></UrUi.Components.avatar>),
          ~s(<UrUi.Components.avatar size={:sm}><UrUi.Components.avatar_fallback>CD</UrUi.Components.avatar_fallback></UrUi.Components.avatar>),
          ~s(<UrUi.Components.avatar size={:sm}><UrUi.Components.avatar_fallback>EF</UrUi.Components.avatar_fallback></UrUi.Components.avatar>),
          ~s(<UrUi.Components.avatar_group_count>+3</UrUi.Components.avatar_group_count>)
        ]
      }
    ]
  end
end
