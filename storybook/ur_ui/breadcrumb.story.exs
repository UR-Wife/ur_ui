defmodule Storybook.UrUi.Breadcrumb do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.breadcrumb/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        description: "Links separated by chevrons, current page last",
        slots: [
          "<UrUi.Components.breadcrumb_list><UrUi.Components.breadcrumb_item><UrUi.Components.breadcrumb_link href=\"/\">Home</UrUi.Components.breadcrumb_link></UrUi.Components.breadcrumb_item><UrUi.Components.breadcrumb_separator /><UrUi.Components.breadcrumb_item><UrUi.Components.breadcrumb_link href=\"/components\">Components</UrUi.Components.breadcrumb_link></UrUi.Components.breadcrumb_item><UrUi.Components.breadcrumb_separator /><UrUi.Components.breadcrumb_item><UrUi.Components.breadcrumb_page>Breadcrumb</UrUi.Components.breadcrumb_page></UrUi.Components.breadcrumb_item></UrUi.Components.breadcrumb_list>"
        ]
      },
      %Variation{
        id: :with_ellipsis,
        description: "Collapsed middle crumbs through the ellipsis part",
        slots: [
          "<UrUi.Components.breadcrumb_list><UrUi.Components.breadcrumb_item><UrUi.Components.breadcrumb_link href=\"/\">Home</UrUi.Components.breadcrumb_link></UrUi.Components.breadcrumb_item><UrUi.Components.breadcrumb_separator /><UrUi.Components.breadcrumb_item><UrUi.Components.breadcrumb_ellipsis /></UrUi.Components.breadcrumb_item><UrUi.Components.breadcrumb_separator /><UrUi.Components.breadcrumb_item><UrUi.Components.breadcrumb_page>Current</UrUi.Components.breadcrumb_page></UrUi.Components.breadcrumb_item></UrUi.Components.breadcrumb_list>"
        ]
      }
    ]
  end
end
