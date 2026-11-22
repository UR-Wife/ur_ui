defmodule Storybook.UrUi.Input do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.input/1
  def render_source, do: :function

  # Mirrors the shadcn docs input-with-label demo. Storybook renders each
  # input with its story id (input-single-<variation>), so the label targets it.
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
        template: labeled("input-single-default", "Display name"),
        attributes: %{id: "display-name", name: "display_name", placeholder: "Display name"}
      },
      %Variation{
        id: :email,
        template: labeled("input-single-email", "Email"),
        attributes: %{id: "email", name: "email", type: "email", placeholder: "you@example.com"}
      },
      %Variation{
        id: :password,
        template: labeled("input-single-password", "Password"),
        attributes: %{id: "password", name: "password", type: "password", required: true}
      },
      %Variation{
        id: :file,
        template: labeled("input-single-file", "Picture"),
        attributes: %{id: "avatar", name: "avatar", type: "file", accept: "image/*"}
      },
      %Variation{
        id: :disabled,
        template: labeled("input-single-disabled", "Disabled"),
        attributes: %{id: "disabled", name: "disabled", value: "Read only", disabled: true}
      },
      %Variation{
        id: :changeset_error,
        template: labeled("input-single-changeset-error", "Email"),
        description: "Real Ecto changeset error through Phoenix.HTML.FormField",
        attributes: %{field: invalid_email_field()}
      },
      %Variation{
        id: :interpolated_error,
        template: labeled("input-single-interpolated-error", "Name"),
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

  defp invalid_email_field do
    changeset =
      {%{email: "bad"}, %{email: :string}}
      |> Ecto.Changeset.cast(%{"email" => "bad"}, [:email])
      |> Ecto.Changeset.add_error(:email, "is invalid")
      |> Map.put(:action, :validate)

    form = Phoenix.HTML.FormData.to_form(changeset, as: :user)
    form[:email]
  end
end
