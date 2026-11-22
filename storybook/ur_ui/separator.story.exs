defmodule Storybook.UrUi.Separator do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.separator/1
  def render_source, do: :function

  # Mirrors the shadcn docs separator demo: a horizontal separator under a
  # heading block, and a vertical one inside a sized (h-5) flex row.
  def template do
    """
    <div>
      <div class="space-y-1">
        <h4 class="text-sm leading-none font-medium">Radix Primitives</h4>
        <p class="text-sm text-muted-foreground">An open-source UI component library.</p>
      </div>
      <.psb-variation/>
    </div>
    """
  end

  defp vertical_template do
    """
    <div class="flex h-5 items-center space-x-4 text-sm">
      <div>Blog</div>
      <.psb-variation/>
      <div>Docs</div>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :horizontal,
        description: "Horizontal divider (decorative)",
        attributes: %{orientation: :horizontal, class: "my-4"}
      },
      %Variation{
        id: :vertical,
        description: "Vertical divider (decorative) in a sized row",
        attributes: %{orientation: :vertical},
        template: vertical_template()
      },
      %Variation{
        id: :semantic,
        description: "Semantic separator (role separator)",
        attributes: %{decorative: false, class: "my-4"}
      },
      %Variation{
        id: :custom_class,
        description: "class extends the base classes",
        attributes: %{class: "my-4 psb:opacity-80"}
      }
    ]
  end
end
