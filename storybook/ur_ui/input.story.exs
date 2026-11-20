defmodule Storybook.UrUi.Input do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.input/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{id: "display-name", name: "display_name", placeholder: "Display name"}
      },
      %Variation{
        id: :email,
        attributes: %{id: "email", name: "email", type: "email", placeholder: "you@example.com"}
      },
      %Variation{
        id: :password,
        attributes: %{id: "password", name: "password", type: "password", required: true}
      },
      %Variation{
        id: :file,
        attributes: %{id: "avatar", name: "avatar", type: "file", accept: "image/*"}
      },
      %Variation{
        id: :disabled,
        attributes: %{id: "disabled", name: "disabled", value: "Read only", disabled: true}
      },
      %Variation{
        id: :changeset_error,
        description: "Real Ecto changeset error through Phoenix.HTML.FormField",
        attributes: %{field: invalid_email_field()}
      },
      %Variation{
        id: :interpolated_error,
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
