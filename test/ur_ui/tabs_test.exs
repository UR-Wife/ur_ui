defmodule UrUi.TabsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @component UrUi.Components
  @root_classes "group/tabs flex gap-2 data-[orientation=horizontal]:flex-col"
  @list_classes "group/tabs-list inline-flex w-fit items-center justify-center rounded-lg p-[3px] text-muted-foreground group-data-[orientation=horizontal]/tabs:h-9 group-data-[orientation=vertical]/tabs:h-fit group-data-[orientation=vertical]/tabs:flex-col data-[variant=line]:rounded-none bg-muted"
  @trigger_classes "relative inline-flex h-[calc(100%-1px)] flex-1 items-center justify-center gap-1.5 rounded-md border border-transparent px-2 py-1 text-sm font-medium whitespace-nowrap text-foreground/60 transition-all group-data-[orientation=vertical]/tabs:w-full group-data-[orientation=vertical]/tabs:justify-start hover:text-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:outline-1 focus-visible:outline-ring disabled:pointer-events-none disabled:opacity-50 group-data-[variant=default]/tabs-list:data-[state=active]:shadow-sm group-data-[variant=line]/tabs-list:data-[state=active]:shadow-none dark:text-muted-foreground dark:hover:text-foreground [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 group-data-[variant=line]/tabs-list:bg-transparent group-data-[variant=line]/tabs-list:data-[state=active]:bg-transparent dark:group-data-[variant=line]/tabs-list:data-[state=active]:border-transparent dark:group-data-[variant=line]/tabs-list:data-[state=active]:bg-transparent data-[state=active]:bg-background data-[state=active]:text-foreground dark:data-[state=active]:border-input dark:data-[state=active]:bg-input/30 dark:data-[state=active]:text-foreground after:absolute after:bg-foreground after:opacity-0 after:transition-opacity group-data-[orientation=horizontal]/tabs:after:inset-x-0 group-data-[orientation=horizontal]/tabs:after:bottom-[-5px] group-data-[orientation=horizontal]/tabs:after:h-0.5 group-data-[orientation=vertical]/tabs:after:inset-y-0 group-data-[orientation=vertical]/tabs:after:-right-1 group-data-[orientation=vertical]/tabs:after:w-0.5 group-data-[variant=line]/tabs-list:data-[state=active]:after:opacity-100"
  @trigger_compatibility "has-[:focus-visible]:border-ring has-[:focus-visible]:ring-[3px] has-[:focus-visible]:ring-ring/50 has-[:focus-visible]:outline-1 has-[:focus-visible]:outline-ring has-[:disabled]:pointer-events-none has-[:disabled]:opacity-50"
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

  test "tabs selects the first tab and exposes matching ARIA relationships" do
    document = render_tabs() |> Floki.parse_fragment!()
    triggers = Floki.find(document, "[role=tab]")
    panels = Floki.find(document, "[role=tabpanel]")

    assert length(Floki.find(document, "[role=tablist]")) == 1
    assert length(triggers) == 2
    assert Floki.attribute(triggers, "aria-selected") == ["true", "false"]

    assert Floki.attribute(triggers, "aria-controls") == [
             "account-tabs-panel-0",
             "account-tabs-panel-1"
           ]

    assert Floki.attribute(panels, "id") == [
             "account-tabs-panel-0",
             "account-tabs-panel-1"
           ]

    assert Floki.attribute(panels, "aria-labelledby") == [
             "account-tabs-trigger-0",
             "account-tabs-trigger-1"
           ]

    assert Floki.attribute(panels, "aria-hidden") == ["false", "true"]
    assert Floki.attribute(Enum.at(panels, 0), "hidden") == []
    assert Floki.attribute(Enum.at(panels, 1), "hidden") == ["hidden"]
  end

  test "tabs uses native radio arrow-key behavior with client-only JS selection commands" do
    document = render_tabs() |> Floki.parse_fragment!()
    triggers = Floki.find(document, "[role=tab]")
    labels = Floki.find(document, "label")

    assert Floki.attribute(triggers, "type") == ["radio", "radio"]
    assert Floki.attribute(triggers, "name") == ["account-tabs-values", "account-tabs-values"]
    assert Floki.attribute(triggers, "tabindex") == ["0", "-1"]
    assert Floki.attribute(labels, "for") == Floki.attribute(triggers, "id")
    assert Floki.attribute(triggers, "aria-labelledby") == Floki.attribute(labels, "id")

    commands = Floki.attribute(triggers, "phx-change")
    assert length(commands) == 2

    for command <- commands do
      assert command =~ "set_attr"
      assert command =~ "remove_attr"
      assert command =~ "aria-selected"
      assert command =~ "aria-hidden"
      assert command =~ "tabindex"
      assert command =~ "hidden"
    end
  end

  test "tabs keeps the trigger surfaces data-state in sync with client-only JS commands" do
    document = render_tabs() |> Floki.parse_fragment!()
    [first, second] = Floki.find(document, "[role=tab]") |> Floki.attribute("phx-change")

    for command <- [first, second] do
      assert command =~ "account-tabs-trigger-wrap-0"
      assert command =~ "account-tabs-trigger-wrap-1"
      assert command =~ "data-state"
      refute command =~ "push"
    end
  end

  test "tabs uses the shadcn root list trigger and content classes" do
    document = render_tabs() |> Floki.parse_fragment!()
    [root] = Floki.find(document, "[data-slot=tabs]")
    [list] = Floki.find(document, "[data-slot=tabs-list]")
    triggers = Floki.find(document, "[data-slot=tabs-trigger-surface]")
    panels = Floki.find(document, "[data-slot=tabs-content]")

    assert Floki.attribute(root, "class") == [@root_classes]
    assert Floki.attribute(root, "data-orientation") == ["horizontal"]
    assert Floki.attribute(list, "class") == [@list_classes]
    assert Floki.attribute(list, "data-variant") == ["default"]

    expected_trigger = "#{@trigger_classes} #{@trigger_compatibility}"
    assert Floki.attribute(triggers, "class") == [expected_trigger, expected_trigger]
    assert Floki.attribute(panels, "class") == [@content_classes, @content_classes]
  end

  test "tabs extends classes and passes global attrs through" do
    html = render_tabs(%{class: "extra", "aria-label": "Account settings"})

    assert html =~ "#{@root_classes} extra"
    assert html =~ ~s(aria-label="Account settings")
  end

  test "tabs falls back to the first tab when default_value matches no trigger" do
    document = render_tabs(%{default_value: "missing"}) |> Floki.parse_fragment!()
    triggers = Floki.find(document, "[role=tab]")

    assert Floki.attribute(triggers, "aria-selected") == ["true", "false"]
  end

  test "tabs renders disabled triggers as disabled radios" do
    html =
      render_tabs(%{
        trigger: [
          Map.put(slot(:trigger, "general", "General"), :disabled, true),
          slot(:trigger, "security", "Security")
        ]
      })

    document = Floki.parse_fragment!(html)
    [first, second] = Floki.find(document, "[role=tab]")

    assert Floki.attribute(first, "disabled") == ["disabled"]
    assert Floki.attribute(second, "disabled") == []
  end
end
