defmodule Storybook.UrUi.Switch do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.switch/1
  def render_source, do: :function

  # Mirrors the shadcn docs switch demo: a labelled switch with a description.
  defp labeled(for_id, text, desc) do
    """
    <div class="flex items-center justify-between gap-4">
      <div class="grid gap-1.5 leading-none">
        <label for="#{for_id}" class="text-sm font-medium">#{text}</label>
        <p class="text-sm text-muted-foreground">#{desc}</p>
      </div>
      <.psb-variation/>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        template: labeled("switch-single-default", "Strict mode", "Enforce additional checks"),
        attributes: %{id: "strict-mode", name: "strict_mode"}
      },
      %Variation{
        id: :checked,
        template:
          labeled("switch-single-checked", "Email notifications", "Receive product updates"),
        attributes: %{id: "notifications", name: "notifications", checked: true}
      },
      %Variation{
        id: :disabled,
        template: labeled("switch-single-disabled", "Disabled", "Currently unavailable"),
        attributes: %{id: "disabled", name: "disabled", disabled: true}
      },
      %Variation{
        id: :sm,
        template: labeled("switch-single-sm", "Compact", "Smaller control"),
        attributes: %{id: "compact", name: "compact", size: :sm}
      }
    ]
  end
end
