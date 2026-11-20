defmodule UrUi.TableTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @component UrUi.Components

  defp inner(content) do
    %{__slot__: :inner_block, inner_block: fn _changed, _argument -> content end}
  end

  defp render_part(name, assigns, content) do
    assigns = assigns |> Map.new() |> Map.put_new(:inner_block, [inner(content)])
    render_component(Function.capture(@component, name, 1), assigns)
  end

  test "table renders its overflow container and table slot" do
    html = render_part(:table, %{}, "Rows")

    assert html =~ ~s(data-slot="table-container")
    assert html =~ ~s(data-slot="table")
    assert html =~ "<table"
    assert html =~ "ur-table"
    assert html =~ "Rows"
  end

  for {name, tag} <- [
        {:table_header, "thead"},
        {:table_body, "tbody"},
        {:table_footer, "tfoot"},
        {:table_row, "tr"},
        {:table_head, "th"},
        {:table_cell, "td"},
        {:table_caption, "caption"}
      ] do
    test "#{name} renders a #{tag} with its shadcn slot" do
      html = render_part(unquote(name), %{}, "Content")
      slot = unquote(name) |> Atom.to_string() |> String.replace("_", "-")

      assert html =~ "<#{unquote(tag)}"
      assert html =~ ~s(data-slot="#{slot}")
      assert html =~ "ur-table__#{slot |> String.replace("table-", "")}"
      assert html =~ "Content"
    end
  end

  test "table_head labels its column scope" do
    html = render_part(:table_head, %{}, "Name")

    assert html =~ ~s(scope="col")
  end

  test "table extends classes and passes global attrs to the table element" do
    html = render_part(:table, %{class: "extra", id: "members", "aria-label": "Members"}, "Rows")

    assert html =~ "ur-table extra"
    assert html =~ ~s(id="members")
    assert html =~ ~s(aria-label="Members")
  end

  test "table renders with no optional attrs or content" do
    html = render_component(Function.capture(@component, :table, 1), %{inner_block: []})

    assert html =~ ~s(data-slot="table")
  end
end
