defmodule Storybook.UrUi.Button do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.button/1
  def render_source, do: :function

  def variations do
    [
      %VariationGroup{
        id: :variants,
        description: "All variants",
        variations: [
          %Variation{id: :default, attributes: %{variant: :default}, slots: ["Default"]},
          %Variation{id: :destructive, attributes: %{variant: :destructive}, slots: ["Destructive"]},
          %Variation{id: :outline, attributes: %{variant: :outline}, slots: ["Outline"]},
          %Variation{id: :secondary, attributes: %{variant: :secondary}, slots: ["Secondary"]},
          %Variation{id: :ghost, attributes: %{variant: :ghost}, slots: ["Ghost"]},
          %Variation{id: :link, attributes: %{variant: :link}, slots: ["Link"]}
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "All sizes",
        variations: [
          %Variation{id: :default, attributes: %{size: :default}, slots: ["Default"]},
          %Variation{id: :xs, attributes: %{size: :xs}, slots: ["XS"]},
          %Variation{id: :sm, attributes: %{size: :sm}, slots: ["SM"]},
          %Variation{id: :lg, attributes: %{size: :lg}, slots: ["LG"]},
          %Variation{id: :icon, attributes: %{size: :icon}, slots: ["★"]},
          %Variation{id: :icon_xs, attributes: %{size: :icon_xs}, slots: ["★"]},
          %Variation{id: :icon_sm, attributes: %{size: :icon_sm}, slots: ["★"]},
          %Variation{id: :icon_lg, attributes: %{size: :icon_lg}, slots: ["★"]}
        ]
      },
      %Variation{
        id: :as_link,
        description: "With href it renders an <a> (shadcn asChild port)",
        attributes: %{href: "/save", variant: :outline},
        slots: ["Save changes"]
      },
      %Variation{
        id: :disabled,
        attributes: %{disabled: true},
        slots: ["Disabled"]
      },
      %Variation{
        id: :custom_class,
        description: "class extends the base classes",
        attributes: %{class: "psb:opacity-80"},
        slots: ["With extra class"]
      }
    ]
  end
end