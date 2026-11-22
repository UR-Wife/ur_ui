defmodule Storybook.UrUi.Pagination do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.pagination/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        description: "Previous, page numbers, ellipsis and next",
        slots: [
          "<UrUi.Components.pagination_content><UrUi.Components.pagination_item><UrUi.Components.pagination_previous href=\"#\" /></UrUi.Components.pagination_item><UrUi.Components.pagination_item><UrUi.Components.pagination_link href=\"#\" is_active>1</UrUi.Components.pagination_link></UrUi.Components.pagination_item><UrUi.Components.pagination_item><UrUi.Components.pagination_link href=\"#\">2</UrUi.Components.pagination_link></UrUi.Components.pagination_item><UrUi.Components.pagination_item><UrUi.Components.pagination_link href=\"#\">3</UrUi.Components.pagination_link></UrUi.Components.pagination_item><UrUi.Components.pagination_item><UrUi.Components.pagination_ellipsis /></UrUi.Components.pagination_item><UrUi.Components.pagination_item><UrUi.Components.pagination_next href=\"#\" /></UrUi.Components.pagination_item></UrUi.Components.pagination_content>"
        ]
      }
    ]
  end
end
