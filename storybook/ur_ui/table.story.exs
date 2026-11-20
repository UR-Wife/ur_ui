defmodule Storybook.UrUi.Table do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.table/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        description: "Header, body and accessible caption",
        slots: [
          "<UrUi.Components.table_caption>Workspace members</UrUi.Components.table_caption>",
          "<UrUi.Components.table_header><UrUi.Components.table_row><UrUi.Components.table_head>Name</UrUi.Components.table_head><UrUi.Components.table_head>Role</UrUi.Components.table_head></UrUi.Components.table_row></UrUi.Components.table_header>",
          "<UrUi.Components.table_body><UrUi.Components.table_row><UrUi.Components.table_cell>Ada Lovelace</UrUi.Components.table_cell><UrUi.Components.table_cell>Owner</UrUi.Components.table_cell></UrUi.Components.table_row><UrUi.Components.table_row><UrUi.Components.table_cell>Grace Hopper</UrUi.Components.table_cell><UrUi.Components.table_cell>Editor</UrUi.Components.table_cell></UrUi.Components.table_row></UrUi.Components.table_body>"
        ]
      },
      %Variation{
        id: :with_footer,
        description: "Summary footer",
        slots: [
          "<UrUi.Components.table_header><UrUi.Components.table_row><UrUi.Components.table_head>Plan</UrUi.Components.table_head><UrUi.Components.table_head>Seats</UrUi.Components.table_head></UrUi.Components.table_row></UrUi.Components.table_header>",
          "<UrUi.Components.table_body><UrUi.Components.table_row><UrUi.Components.table_cell>Team</UrUi.Components.table_cell><UrUi.Components.table_cell>8</UrUi.Components.table_cell></UrUi.Components.table_row></UrUi.Components.table_body>",
          "<UrUi.Components.table_footer><UrUi.Components.table_row><UrUi.Components.table_cell>Total</UrUi.Components.table_cell><UrUi.Components.table_cell>8</UrUi.Components.table_cell></UrUi.Components.table_row></UrUi.Components.table_footer>"
        ]
      },
      %Variation{
        id: :selected_row,
        description: "Selection supplied through rest data attributes",
        slots: [
          "<UrUi.Components.table_header><UrUi.Components.table_row><UrUi.Components.table_head>Member</UrUi.Components.table_head><UrUi.Components.table_head>Status</UrUi.Components.table_head></UrUi.Components.table_row></UrUi.Components.table_header>",
          "<UrUi.Components.table_body><UrUi.Components.table_row data-state=\"selected\"><UrUi.Components.table_cell>Ada Lovelace</UrUi.Components.table_cell><UrUi.Components.table_cell>Selected</UrUi.Components.table_cell></UrUi.Components.table_row></UrUi.Components.table_body>"
        ]
      },
      %Variation{
        id: :empty,
        description: "Empty body supplied by the caller",
        slots: [
          "<UrUi.Components.table_header><UrUi.Components.table_row><UrUi.Components.table_head>Members</UrUi.Components.table_head></UrUi.Components.table_row></UrUi.Components.table_header>",
          "<UrUi.Components.table_body><UrUi.Components.table_row><UrUi.Components.table_cell>No members found.</UrUi.Components.table_cell></UrUi.Components.table_row></UrUi.Components.table_body>"
        ]
      }
    ]
  end
end
