defmodule UrUi.TableTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @component UrUi.Components
  @classes %{
    "table-container" => "relative w-full overflow-x-auto",
    "table" => "w-full caption-bottom text-sm",
    "table-header" => "[&_tr]:border-b",
    "table-body" => "[&_tr:last-child]:border-0",
    "table-footer" => "bg-muted/50 border-t font-medium [&>tr]:last:border-b-0",
    "table-row" => "hover:bg-muted/50 data-[state=selected]:bg-muted border-b transition-colors",
    "table-head" =>
      "text-foreground h-10 px-2 text-left align-middle font-medium whitespace-nowrap [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]",
    "table-cell" =>
      "p-2 align-middle whitespace-nowrap [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]",
    "table-caption" => "text-muted-foreground mt-4 text-sm"
  }

  defp inner(content) do
    %{__slot__: :inner_block, inner_block: fn _changed, _argument -> content end}
  end

  defp render_part(name, assigns, content) do
    assigns = assigns |> Map.new() |> Map.put_new(:inner_block, [inner(content)])
    render_component(Function.capture(@component, name, 1), assigns)
  end

  defp assert_classes(html, slot, custom \\ nil) do
    expected = [@classes[slot], custom] |> Enum.reject(&is_nil/1) |> Enum.join(" ")
    [part] = Floki.parse_fragment!(html) |> Floki.find("[data-slot='#{slot}']")
    assert Floki.attribute(part, "class") == [expected]
  end

  test "table renders its overflow container and table slot" do
    html = render_part(:table, %{}, "Rows")

    assert_classes(html, "table-container")
    assert_classes(html, "table")
    assert html =~ "<table"
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
      assert_classes(html, slot)
      assert html =~ "Content"
    end
  end

  test "table_head labels its column scope" do
    html = render_part(:table_head, %{}, "Name")

    assert html =~ ~s(scope="col")
  end

  test "table extends classes and passes global attrs to the table element" do
    html = render_part(:table, %{class: "extra", id: "members", "aria-label": "Members"}, "Rows")

    assert_classes(html, "table", "extra")
    assert html =~ ~s(id="members")
    assert html =~ ~s(aria-label="Members")
  end

  test "table renders with no optional attrs or content" do
    html = render_component(Function.capture(@component, :table, 1), %{inner_block: []})

    assert html =~ ~s(data-slot="table")
  end
end
