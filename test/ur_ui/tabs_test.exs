defmodule UrUi.TabsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @component UrUi.Components
  @root_classes "group/tabs flex gap-2 data-[orientation=horizontal]:flex-col"
  @list_classes "group/tabs-list inline-flex w-fit items-center justify-center rounded-lg p-[3px] text-muted-foreground group-data-[orientation=horizontal]/tabs:h-9 group-data-[orientation=vertical]/tabs:h-fit group-data-[orientation=vertical]/tabs:flex-col data-[variant=line]:rounded-none bg-muted"
  @trigger_classes "relative inline-flex h-[calc(100%-1px)] flex-1 items-center justify-center gap-1.5 rounded-md border border-transparent px-2 py-1 text-sm font-medium whitespace-nowrap text-foreground/60 transition-all group-data-[orientation=vertical]/tabs:w-full group-data-[orientation=vertical]/tabs:justify-start hover:text-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:outline-1 focus-visible:outline-ring disabled:pointer-events-none disabled:opacity-50 group-data-[variant=default]/tabs-list:data-[state=active]:shadow-sm group-data-[variant=line]/tabs-list:data-[state=active]:shadow-none dark:text-muted-foreground dark:hover:text-foreground [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 group-data-[variant=line]/tabs-list:bg-transparent group-data-[variant=line]/tabs-list:data-[state=active]:bg-transparent dark:group-data-[variant=line]/tabs-list:data-[state=active]:border-transparent dark:group-data-[variant=line]/tabs-list:data-[state=active]:bg-transparent data-[state=active]:bg-background data-[state=active]:text-foreground dark:data-[state=active]:border-input dark:data-[state=active]:bg-input/30 dark:data-[state=active]:text-foreground after:absolute after:bg-foreground after:opacity-0 after:transition-opacity group-data-[orientation=horizontal]/tabs:after:inset-x-0 group-data-[orientation=horizontal]/tabs:after:bottom-[-5px] group-data-[orientation=horizontal]/tabs:after:h-0.5 group-data-[orientation=vertical]/tabs:after:inset-y-0 group-data-[orientation=vertical]/tabs:after:-right-1 group-data-[orientation=vertical]/tabs:after:w-0.5 group-data-[variant=line]/tabs-list:data-[state=active]:after:opacity-100"
  @content_classes "flex-1 outline-none"

  defp slot(name, value, content) do
    %{
      __slot__: name,
      value: value,
      inner_block: fn _changed, _argument -> content end
    }
  end

  defp render_tabs(assigns \\ %{}) do
    defaults = %{
      id: "account-tabs",
      trigger: [
        slot(:trigger, "general", "General"),
        slot(:trigger, "security", "Security")
      ],
      content: [
        slot(:content, "general", "General panel"),
        slot(:content, "security", "Security panel")
      ]
    }

    render_component(
      Function.capture(@component, :tabs, 1),
      Map.merge(defaults, Map.new(assigns))
    )
  end

  defp parse(assigns \\ %{}), do: render_tabs(assigns) |> Floki.parse_fragment!()

  test "tabs renders shadcn's tablist of button tabs and tabpanels" do
    document = parse()
    [list] = Floki.find(document, "[role=tablist]")
    triggers = Floki.find(document, "[role=tab]")
    panels = Floki.find(document, "[role=tabpanel]")

    assert Floki.attribute(list, "aria-orientation") == ["horizontal"]
    assert length(triggers) == 2
    assert Enum.map(triggers, fn {tag, _, _} -> tag end) == ["button", "button"]
    assert Floki.attribute(triggers, "type") == ["button", "button"]
    assert Floki.attribute(triggers, "data-slot") == ["tabs-trigger", "tabs-trigger"]
    assert Enum.map(triggers, &String.trim(Floki.text(&1))) == ["General", "Security"]
    assert Floki.find(document, "input") == []
    assert Floki.find(document, "label") == []

    assert length(panels) == 2
    assert Floki.attribute(panels, "data-slot") == ["tabs-content", "tabs-content"]
    assert Floki.attribute(panels, "tabindex") == ["0", "0"]
  end

  test "tabs selects the first tab and links tabs and panels with ARIA" do
    document = parse()
    triggers = Floki.find(document, "[role=tab]")
    panels = Floki.find(document, "[role=tabpanel]")

    assert Floki.attribute(triggers, "aria-selected") == ["true", "false"]
    assert Floki.attribute(triggers, "data-state") == ["active", "inactive"]
    assert Floki.attribute(triggers, "tabindex") == ["0", "-1"]

    assert Floki.attribute(triggers, "aria-controls") == Floki.attribute(panels, "id")
    assert Floki.attribute(panels, "aria-labelledby") == Floki.attribute(triggers, "id")

    assert Enum.uniq(Floki.attribute(triggers, "id") ++ Floki.attribute(panels, "id")) |> length() ==
             4

    assert Floki.attribute(panels, "data-state") == ["active", "inactive"]
    assert Floki.attribute(Enum.at(panels, 0), "hidden") == []
    assert Floki.attribute(Enum.at(panels, 1), "hidden") != []
  end

  test "tabs opens default_value and falls back to the first tab when it matches nothing" do
    assert parse(%{default_value: "security"})
           |> Floki.find("[role=tab]")
           |> Floki.attribute("aria-selected") == ["false", "true"]

    assert parse(%{default_value: "missing"})
           |> Floki.find("[role=tab]")
           |> Floki.attribute("aria-selected") == ["true", "false"]
  end

  test "clicking a tab selects it on the client without a server round trip" do
    document = parse()
    triggers = Floki.find(document, "[role=tab]")
    [panel_one, panel_two] = Floki.attribute(document, "[role=tabpanel]", "id")
    commands = Floki.attribute(triggers, "phx-click")

    assert length(commands) == 2

    for command <- commands do
      refute command =~ "push"
      assert command =~ "aria-selected"
      assert command =~ "tabindex"
      assert command =~ "data-state"
      assert command =~ "hidden"
      assert command =~ panel_one
      assert command =~ panel_two
    end
  end

  test "keyboard navigation uses the colocated hook, with no inline script" do
    html = render_tabs()
    [list] = html |> Floki.parse_fragment!() |> Floki.find("[role=tablist]")

    assert Floki.attribute(list, "phx-hook") == ["UrUi.Components.Tabs"]
    assert Floki.attribute(list, "id") == ["account-tabs-list"]
    refute html =~ "<script"
    refute html =~ ~r/\son[a-z]+=/
  end

  test "disabled tabs are disabled buttons that are never selected" do
    document =
      parse(%{
        trigger: [
          slot(:trigger, "general", "General"),
          Map.put(slot(:trigger, "security", "Security"), :disabled, true)
        ]
      })

    [first, second] = Floki.find(document, "[role=tab]")

    assert Floki.attribute(first, "disabled") == []
    assert Floki.attribute(second, "disabled") != []
    assert Floki.attribute(second, "data-disabled") == [""]
    assert Floki.attribute(second, "aria-selected") == ["false"]
  end

  test "tabs uses the shadcn root, list, trigger and content classes" do
    document = parse()
    [root] = Floki.find(document, "[data-slot=tabs]")
    [list] = Floki.find(document, "[data-slot=tabs-list]")
    triggers = Floki.find(document, "[data-slot=tabs-trigger]")
    panels = Floki.find(document, "[data-slot=tabs-content]")

    assert Floki.attribute(root, "class") == [@root_classes]
    assert Floki.attribute(root, "data-orientation") == ["horizontal"]
    assert Floki.attribute(list, "class") == [@list_classes]
    assert Floki.attribute(list, "data-variant") == ["default"]
    assert Floki.attribute(triggers, "class") == [@trigger_classes, @trigger_classes]
    assert Floki.attribute(panels, "class") == [@content_classes, @content_classes]
  end

  test "a trigger without matching content gets no dangling aria-controls" do
    document = parse(%{content: [slot(:content, "general", "General panel")]})
    [first, second] = Floki.find(document, "[role=tab]")
    [panel] = Floki.find(document, "[role=tabpanel]")

    assert Floki.attribute(first, "aria-controls") == Floki.attribute(panel, "id")
    assert Floki.attribute(second, "aria-controls") == []
  end

  test "tabs extends classes and passes global attrs through" do
    html = render_tabs(%{class: "extra", "aria-label": "Account settings"})

    assert html =~ "#{@root_classes} extra"
    assert html =~ ~s(aria-label="Account settings")
  end
end
