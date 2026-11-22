defmodule UrUi.FieldTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  defp inner(content),
    do: %{__slot__: :inner_block, inner_block: fn _changed, _arg -> content end}

  test "field renders a labelled group with default vertical orientation" do
    html = render_component(&Components.field/1, %{inner_block: inner("x")})

    assert html =~ ~s(role="group")
    assert html =~ ~s(data-slot="field")
    assert html =~ ~s(data-orientation="vertical")
    assert html =~ "group/field flex w-full gap-3"
    assert html =~ "flex-col"
  end

  test "field applies horizontal orientation" do
    html =
      render_component(&Components.field/1, %{orientation: :horizontal, inner_block: inner("x")})

    assert html =~ ~s(data-orientation="horizontal")
    assert html =~ "flex-row items-center"
  end

  test "field_label renders a label" do
    html =
      render_component(&Components.field_label/1, %{for: "email", inner_block: inner("Email")})

    assert html =~ "<label"
    assert html =~ ~s(for="email")
    assert html =~ ~s(data-slot="field-label")
  end

  test "field_description renders muted copy" do
    html = render_component(&Components.field_description/1, %{inner_block: inner("Help text")})

    assert html =~ "<p"
    assert html =~ ~s(data-slot="field-description")
    assert html =~ "text-muted-foreground"
    assert html =~ "Help text"
  end

  test "field_error renders a single message with role alert" do
    html = render_component(&Components.field_error/1, %{errors: [{"is invalid", []}]})

    assert html =~ ~s(role="alert")
    assert html =~ ~s(data-slot="field-error")
    assert html =~ "is invalid"
  end

  test "field_error interpolates changeset options and lists multiple errors" do
    html =
      render_component(&Components.field_error/1, %{
        errors: [{"at least %{count} chars", [count: 3]}, {"must be unique", []}]
      })

    assert html =~ "at least 3 chars"
    assert html =~ "must be unique"
    assert html =~ "<ul"
  end
end
