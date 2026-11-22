defmodule Storybook.UrUi.Textarea do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.textarea/1
  def render_source, do: :function

  # Mirrors the shadcn docs textarea-with-label demo. Storybook renders each
  # textarea with its story id (textarea-single-<variation>), so the label targets it.
  defp labeled(for_id, text) do
    """
    <div class="grid w-full max-w-sm items-center gap-3">
      <UrUi.Components.label for="#{for_id}">#{text}</UrUi.Components.label>
      <.psb-variation/>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        template: labeled("textarea-single-default", "Bio"),
        attributes: %{id: "bio", name: "bio", placeholder: "Bio"}
      },
      %Variation{
        id: :disabled,
        template: labeled("textarea-single-disabled", "Disabled"),
        attributes: %{id: "disabled", name: "disabled", value: "Read only", disabled: true}
      },
      %Variation{
        id: :changeset_error,
        template: labeled("textarea-single-changeset-error", "Bio"),
        description: "Real Ecto changeset error through Phoenix.HTML.FormField",
        attributes: %{field: invalid_bio_field()}
      },
      %Variation{
        id: :interpolated_error,
        template: labeled("textarea-single-interpolated-error", "Name"),
        description: "Changeset error options are interpolated",
        attributes: %{
          id: "name",
          name: "name",
          value: "x",
          errors: [{"should be at least %{count} characters", [count: 3]}]
        }
      }
    ]
  end

  defp invalid_bio_field do
    changeset =
      {%{bio: "bad"}, %{bio: :string}}
      |> Ecto.Changeset.cast(%{"bio" => "bad"}, [:bio])
      |> Ecto.Changeset.add_error(:bio, "is invalid")
      |> Map.put(:action, :validate)

    form = Phoenix.HTML.FormData.to_form(changeset, as: :user)
    form[:bio]
  end
end