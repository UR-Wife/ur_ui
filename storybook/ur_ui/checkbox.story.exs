defmodule Storybook.UrUi.Checkbox do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.checkbox/1
  def render_source, do: :function

  # Mirrors the shadcn docs checkbox-with-text demo. Storybook renders each
  # checkbox with its story id (checkbox-single-<variation>), so the label
  # targets it.
  defp labeled(for_id, text) do
    """
    <div class="flex items-center gap-2">
      <.psb-variation/>
      <label for="#{for_id}" class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">#{text}</label>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        template: labeled("checkbox-single-default", "Accept terms and conditions"),
        attributes: %{id: "terms"}
      },
      %Variation{
        id: :checked,
        template: labeled("checkbox-single-checked", "Accept terms and conditions"),
        attributes: %{id: "terms", checked: true}
      },
      %Variation{
        id: :disabled,
        template: labeled("checkbox-single-disabled", "Accept terms and conditions"),
        attributes: %{id: "terms", disabled: true}
      }
    ]
  end
end
