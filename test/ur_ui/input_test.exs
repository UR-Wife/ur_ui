defmodule UrUi.InputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @component UrUi.Components

  defp render_input(assigns \\ %{}) do
    render_component(Function.capture(@component, :input, 1), Map.new(assigns))
  end

  test "input renders a text input with no optional attrs" do
    html = render_input()

    assert html =~ "<input"
    assert html =~ ~s(type="text")
    assert html =~ ~s(data-slot="input")
    assert html =~ "ur-input"
    refute html =~ "ur-input--invalid"
  end

  test "input passes through shadcn-supported native input types" do
    for type <- ~w(text email password file) do
      assert render_input(%{type: type}) =~ ~s(type="#{type}")
    end
  end

  test "input extends classes and passes global attrs" do
    html =
      render_input(%{
        class: "extra",
        id: "email",
        name: "email",
        placeholder: "you@example.com",
        autocomplete: "email",
        required: true,
        disabled: true
      })

    assert html =~ "ur-input extra"
    assert html =~ ~s(id="email")
    assert html =~ ~s(name="email")
    assert html =~ ~s(placeholder="you@example.com")
    assert html =~ ~s(autocomplete="email")
    assert html =~ ~s(required)
    assert html =~ ~s(disabled)
  end

  test "input derives id name and value from a Phoenix form field" do
    changeset =
      {%{email: "ada@example.com"}, %{email: :string}}
      |> Ecto.Changeset.cast(%{"email" => "ada@example.com"}, [:email])

    form = Phoenix.HTML.FormData.to_form(changeset, as: :user)
    html = render_input(%{field: form[:email]})

    assert html =~ ~s(id="user_email")
    assert html =~ ~s(name="user[email]")
    assert html =~ ~s(value="ada@example.com")
  end

  test "input shows changeset errors and links them to the field" do
    changeset =
      {%{email: "bad"}, %{email: :string}}
      |> Ecto.Changeset.cast(%{"email" => "bad"}, [:email])
      |> Ecto.Changeset.add_error(:email, "is invalid")
      |> Map.put(:action, :validate)

    form = Phoenix.HTML.FormData.to_form(changeset, as: :user)
    html = render_input(%{field: form[:email]})

    assert html =~ "is invalid"
    assert html =~ "ur-input--invalid"
    assert html =~ ~s(aria-invalid="true")
    assert html =~ ~s(aria-describedby="user_email-errors")
    assert html =~ ~s(id="user_email-errors")
    assert html =~ ~s(data-slot="input-error")
  end

  test "explicit errors interpolate changeset options" do
    html =
      render_input(%{
        id: "name",
        errors: [{"should be at least %{count} characters", [count: 3]}]
      })

    assert html =~ "should be at least 3 characters"
    assert html =~ ~s(aria-describedby="name-errors")
  end

  test "explicit attrs override form field defaults" do
    changeset =
      {%{email: "old@example.com"}, %{email: :string}}
      |> Ecto.Changeset.cast(%{}, [:email])

    form = Phoenix.HTML.FormData.to_form(changeset, as: :user)

    html =
      render_input(%{
        field: form[:email],
        id: "contact",
        name: "contact",
        value: "new@example.com"
      })

    assert html =~ ~s(id="contact")
    assert html =~ ~s(name="contact")
    assert html =~ ~s(value="new@example.com")
  end

  test "file inputs never render a value attribute" do
    html = render_input(%{type: "file", value: "must-not-appear"})

    refute html =~ "value="
    refute html =~ "must-not-appear"
  end
end
