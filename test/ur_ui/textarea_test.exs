defmodule UrUi.TextareaTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @component UrUi.Components
  @base "flex field-sizing-content min-h-16 w-full rounded-md border border-input bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 md:text-sm dark:bg-input/30 dark:aria-invalid:ring-destructive/40"

  defp assert_textarea_classes(html, custom \\ nil) do
    expected = [@base, custom] |> Enum.reject(&is_nil/1) |> Enum.join(" ")
    [textarea] = Floki.parse_fragment!(html) |> Floki.find("[data-slot=textarea]")
    assert Floki.attribute(textarea, "class") == [expected]
  end

  defp render_textarea(assigns \\ %{}) do
    render_component(Function.capture(@component, :textarea, 1), Map.new(assigns))
  end

  test "textarea renders a textarea with no optional attrs" do
    html = render_textarea()

    assert html =~ "<textarea"
    assert html =~ ~s(data-slot="textarea")
    assert_textarea_classes(html)
    refute html =~ "ur-textarea"
  end

  test "textarea extends classes and passes global attrs" do
    html =
      render_textarea(%{
        class: "extra",
        id: "bio",
        name: "bio",
        placeholder: "Tell us about yourself",
        rows: 4,
        required: true,
        disabled: true
      })

    assert_textarea_classes(html, "extra")
    assert html =~ ~s(id="bio")
    assert html =~ ~s(name="bio")
    assert html =~ ~s(placeholder="Tell us about yourself")
    assert html =~ ~s(rows="4")
    assert html =~ ~s(required)
    assert html =~ ~s(disabled)
  end

  test "textarea renders its value as text content" do
    html = render_textarea(%{id: "bio", value: "Hello world"})

    assert html =~ "Hello world"
    assert html =~ ~s(<textarea)
    refute html =~ ~s(value="Hello world")
  end

  test "textarea derives id name and value from a Phoenix form field" do
    changeset =
      {%{bio: "hello world"}, %{bio: :string}}
      |> Ecto.Changeset.cast(%{"bio" => "hello world"}, [:bio])

    form = Phoenix.HTML.FormData.to_form(changeset, as: :user)
    html = render_textarea(%{field: form[:bio]})

    assert html =~ ~s(id="user_bio")
    assert html =~ ~s(name="user[bio]")
    assert html =~ "hello world"
  end

  test "textarea shows changeset errors and links them to the field" do
    changeset =
      {%{bio: "bad"}, %{bio: :string}}
      |> Ecto.Changeset.cast(%{"bio" => "bad"}, [:bio])
      |> Ecto.Changeset.add_error(:bio, "is invalid")
      |> Map.put(:action, :validate)

    form = Phoenix.HTML.FormData.to_form(changeset, as: :user)
    html = render_textarea(%{field: form[:bio]})

    assert html =~ "is invalid"
    assert_textarea_classes(html)
    assert html =~ "text-destructive text-sm"
    assert html =~ ~s(aria-invalid="true")
    assert html =~ ~s(aria-describedby="user_bio-errors")
    assert html =~ ~s(id="user_bio-errors")
    assert html =~ ~s(data-slot="textarea-error")
  end

  test "explicit errors interpolate changeset options" do
    html =
      render_textarea(%{
        id: "name",
        errors: [{"should be at least %{count} characters", [count: 3]}]
      })

    assert html =~ "should be at least 3 characters"
    assert html =~ ~s(aria-describedby="name-errors")
  end

  test "explicit attrs override form field defaults" do
    changeset =
      {%{bio: "field-value"}, %{bio: :string}}
      |> Ecto.Changeset.cast(%{}, [:bio])

    form = Phoenix.HTML.FormData.to_form(changeset, as: :user)

    html =
      render_textarea(%{
        field: form[:bio],
        id: "contact",
        name: "contact",
        value: "new"
      })

    assert html =~ ~s(id="contact")
    assert html =~ ~s(name="contact")
    assert html =~ "new"
    refute html =~ "field-value"
  end
end