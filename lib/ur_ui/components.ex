defmodule UrUi.Components do
  @moduledoc """
  UR UI function components — shadcn/ui new-york-v4 ported to Phoenix.
  Styling uses shadcn's neutral theme and Tailwind v4 utility classes.

  Conventions:

  - variants and sizes are atoms (`variant: :destructive`, `size: :sm`)
  - `class` extends, never replaces, the base classes
  - optional attrs have defaults; missing optional attrs never crash
  - global attributes (`id`, `aria-*`, `phx-*`, `data-*`) pass through
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @button_base "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive"
  @button_variants %{
    default: "bg-primary text-primary-foreground shadow-xs hover:bg-primary/90",
    destructive:
      "bg-destructive text-white shadow-xs hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60",
    outline:
      "border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground dark:bg-input/30 dark:border-input dark:hover:bg-input/50",
    secondary: "bg-secondary text-secondary-foreground shadow-xs hover:bg-secondary/80",
    ghost: "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50",
    link: "text-primary underline-offset-4 hover:underline"
  }
  @button_sizes %{
    default: "h-9 px-4 py-2 has-[>svg]:px-3",
    xs:
      "h-6 gap-1.5 rounded-md px-2 text-xs has-[>svg]:px-1.5 [&_svg:not([class*='size-'])]:size-3",
    sm: "h-8 rounded-md gap-1.5 px-3 has-[>svg]:px-2.5",
    lg: "h-10 rounded-md px-6 has-[>svg]:px-4",
    icon: "size-9",
    icon_xs: "size-6 rounded-md [&_svg:not([class*='size-'])]:size-3",
    icon_sm: "size-8",
    icon_lg: "size-10"
  }
  @badge_base "inline-flex w-fit shrink-0 items-center justify-center gap-1 overflow-hidden rounded-full border px-2 py-0.5 text-xs font-medium whitespace-nowrap transition-[color,box-shadow] focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 [&>svg]:pointer-events-none [&>svg]:size-3"
  # shadcn's classes as rendered: its cn() (tailwind-merge) drops the base
  # border-transparent when a variant sets a border colour (:outline), so
  # border-transparent lives on every other variant instead.
  @badge_variants %{
    default: "border-transparent bg-primary text-primary-foreground [a&]:hover:bg-primary/90",
    secondary:
      "border-transparent bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90",
    destructive:
      "border-transparent bg-destructive text-white focus-visible:ring-destructive/20 dark:bg-destructive/60 dark:focus-visible:ring-destructive/40 [a&]:hover:bg-destructive/90",
    outline:
      "border-border text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
    ghost: "border-transparent [a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
    link: "border-transparent text-primary underline-offset-4 [a&]:hover:underline"
  }

  @doc """
  Button (shadcn `Button`).

  Renders a `<button>`; when `href` is given it renders an `<a>` instead
  (the shadcn `asChild` link use-case).

  ## Variants

  `:default`, `:destructive`, `:outline`, `:secondary`, `:ghost`, `:link`

  ## Sizes

  `:default`, `:xs`, `:sm`, `:lg`, `:icon`, `:icon_xs`, `:icon_sm`, `:icon_lg`
  """
  attr(:variant, :atom,
    default: :default,
    values: [:default, :destructive, :outline, :secondary, :ghost, :link],
    doc: "visual variant"
  )

  attr(:size, :atom,
    default: :default,
    values: [:default, :xs, :sm, :lg, :icon, :icon_xs, :icon_sm, :icon_lg],
    doc: "size variant"
  )

  attr(:type, :string, default: "button", doc: "button type; ignored when href is given")
  attr(:href, :string, default: nil, doc: "renders an <a> when given")
  attr(:disabled, :boolean, default: false, doc: "disables the button")
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def button(%{href: href} = assigns) when is_binary(href) do
    assigns = assign(assigns, :classes, button_classes(assigns))

    ~H"""
    <a href={@href} class={@classes} data-slot="button" data-variant={@variant} data-size={@size} aria-disabled={@disabled} {@rest}>
      {render_slot(@inner_block)}
    </a>
    """
  end

  def button(assigns) do
    assigns = assign(assigns, :classes, button_classes(assigns))

    ~H"""
    <button type={@type} class={@classes} data-slot="button" data-variant={@variant} data-size={@size} disabled={@disabled} {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp button_classes(assigns) do
    [
      @button_base,
      @button_variants[assigns.variant],
      @button_sizes[assigns.size],
      assigns[:class]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @toggle_base "inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap transition-[color,box-shadow] outline-none hover:bg-muted hover:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
  @toggle_variants %{
    default: "bg-transparent",
    outline:
      "border border-input bg-transparent shadow-xs hover:bg-accent hover:text-accent-foreground"
  }
  @toggle_sizes %{
    default: "h-9 min-w-9 px-2",
    sm: "h-8 min-w-8 px-1.5",
    lg: "h-10 min-w-10 px-2.5"
  }

  @doc """
  Toggle (shadcn `Toggle`) — a pressable button with a pressed/on state.

  Toggling runs client-side through `Phoenix.LiveView.JS`, so no server round
  trip is needed.

  ## Variants

  `:default`, `:outline`

  ## Sizes

  `:default`, `:sm`, `:lg`
  """
  attr(:variant, :atom,
    default: :default,
    values: [:default, :outline],
    doc: "visual variant"
  )

  attr(:size, :atom, default: :default, values: [:default, :sm, :lg], doc: "size variant")
  attr(:pressed, :boolean, default: false, doc: "initial pressed state")
  attr(:disabled, :boolean, default: false, doc: "disables the toggle")
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def toggle(assigns) do
    assigns = assign(assigns, :classes, toggle_classes(assigns))

    ~H"""
    <button
      type="button"
      class={@classes}
      data-slot="toggle"
      data-variant={@variant}
      data-size={@size}
      data-state={if @pressed, do: "on", else: "off"}
      data-disabled={@disabled && ""}
      aria-pressed={to_string(@pressed)}
      disabled={@disabled}
      phx-click={if @disabled, do: nil, else: toggle_js()}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp toggle_classes(assigns) do
    [
      @toggle_base,
      @toggle_variants[assigns.variant],
      @toggle_sizes[assigns.size],
      assigns[:class]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp toggle_js do
    %JS{}
    |> JS.toggle_attribute({"aria-pressed", "true", "false"})
    |> JS.toggle_attribute({"data-state", "on", "off"})
  end

  @toggle_group_item_heights %{default: "h-9", sm: "h-8", lg: "h-10"}

  @doc """
  Toggle group (shadcn `ToggleGroup`) — a group of toggle buttons. `type:
  :single` (the default) behaves like a radio group (`role="radiogroup"`,
  items `role="radio" aria-checked`); `:multiple` renders a toolbar where every
  item toggles independently (`aria-pressed`). Selection runs client-side
  through `Phoenix.LiveView.JS`; arrow keys move focus through the
  `UrUiToggleGroup` hook (from `UrUiHooks`, see USAGE.md).

  ## Variants

  `:default`, `:outline` — Sizes: `:default`, `:sm`, `:lg`
  """
  attr(:id, :string, required: true)
  attr(:type, :atom, default: :single, values: [:single, :multiple])
  attr(:variant, :atom, default: :default, values: [:default, :outline])
  attr(:size, :atom, default: :default, values: [:default, :sm, :lg])
  attr(:spacing, :integer, default: 0)
  attr(:default_value, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot :item do
    attr(:value, :string, required: true)
    attr(:disabled, :boolean)
  end

  def toggle_group(assigns) do
    items = assigns[:item] || []
    selected_values = toggle_group_selected(assigns)

    items =
      items
      |> Enum.with_index()
      |> Enum.map(fn {item, index} ->
        value = item[:value]

        item
        |> Map.put_new(:disabled, nil)
        |> Map.put(:index, index)
        |> Map.put(:id, "#{assigns.id}-item-#{index}")
        |> Map.put(:checked, value in selected_values)
        |> Map.put(
          :tabindex,
          toggle_group_tabindex(assigns[:type], index, value in selected_values)
        )
      end)

    assigns =
      assign(assigns,
        items: items,
        classes: toggle_group_classes(assigns),
        item_classes: toggle_group_item_classes(assigns)
      )

    ~H"""
    <div
      id={@id}
      role={if @type == :single, do: "radiogroup", else: "toolbar"}
      data-type={@type}
      data-slot="toggle-group"
      data-variant={@variant}
      data-size={@size}
      data-spacing={@spacing}
      class={@classes}
      phx-hook="UrUiToggleGroup"
      {@rest}
    >
      <button
        :for={item <- @items}
        type="button"
        id={item.id}
        value={item.value}
        role={if @type == :single, do: "radio"}
        aria-checked={if @type == :single, do: to_string(item.checked)}
        aria-pressed={if @type == :multiple, do: to_string(item.checked)}
        data-state={if item.checked, do: "on", else: "off"}
        data-disabled={item.disabled && ""}
        data-variant={@variant}
        data-size={@size}
        data-spacing={@spacing}
        disabled={item.disabled}
        tabindex={item.tabindex}
        data-slot="toggle-group-item"
        class={@item_classes}
        phx-click={if item.disabled, do: nil, else: toggle_group_select_js(@type, @items, item.index)}
      >
        {render_slot(item)}
      </button>
    </div>
    """
  end

  defp toggle_group_selected(%{type: :multiple} = assigns) do
    assigns[:default_value] |> List.wrap()
  end

  defp toggle_group_selected(assigns) do
    values = Enum.map(assigns[:item] || [], & &1[:value])

    case assigns[:default_value] do
      nil -> if values == [], do: [], else: [hd(values)]
      value -> if value in values, do: [value], else: if(values == [], do: [], else: [hd(values)])
    end
  end

  defp toggle_group_tabindex(:single, _index, checked), do: if(checked, do: "0", else: "-1")
  defp toggle_group_tabindex(:multiple, index, _checked), do: if(index == 0, do: "0", else: "-1")

  defp toggle_group_classes(assigns) do
    [
      "group/toggle-group flex w-fit items-center gap-#{assigns[:spacing]} rounded-md data-[spacing=default]:data-[variant=outline]:shadow-xs",
      assigns[:class]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp toggle_group_item_classes(assigns) do
    [
      @toggle_base,
      @toggle_variants[assigns[:variant]],
      @toggle_group_item_heights[assigns[:size]],
      "w-auto min-w-0 shrink-0 px-3 focus:z-10 focus-visible:z-10",
      "data-[spacing=0]:rounded-none data-[spacing=0]:shadow-none data-[spacing=0]:first:rounded-l-md data-[spacing=0]:last:rounded-r-md data-[spacing=0]:data-[variant=outline]:border-l-0 data-[spacing=0]:data-[variant=outline]:first:border-l"
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(" ")
  end

  defp toggle_group_select_js(:single, items, selected_index) do
    Enum.reduce(items, %JS{}, fn item, js ->
      checked = item.index == selected_index
      target = "##{Phoenix.HTML.css_escape(item.id)}"
      state = if(checked, do: "on", else: "off")

      js
      |> JS.set_attribute({"aria-checked", to_string(checked)}, to: target)
      |> JS.set_attribute({"data-state", state}, to: target)
      |> JS.set_attribute({"tabindex", if(checked, do: "0", else: "-1")}, to: target)
    end)
  end

  defp toggle_group_select_js(:multiple, _items, _selected_index) do
    %JS{}
    |> JS.toggle_attribute({"aria-pressed", "true", "false"})
    |> JS.toggle_attribute({"data-state", "on", "off"})
  end

  @switch_base "peer group/switch inline-flex shrink-0 items-center rounded-full border border-transparent shadow-xs transition-all outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 data-[size=default]:h-[1.15rem] data-[size=default]:w-8 data-[size=sm]:h-3.5 data-[size=sm]:w-6 data-[state=checked]:bg-primary data-[state=unchecked]:bg-input dark:data-[state=unchecked]:bg-input/80"
  @switch_thumb_classes "pointer-events-none block rounded-full bg-background ring-0 transition-transform group-data-[size=default]/switch:size-4 group-data-[size=sm]/switch:size-3 data-[state=checked]:translate-x-[calc(100%-2px)] data-[state=unchecked]:translate-x-0 dark:data-[state=checked]:bg-primary-foreground dark:data-[state=unchecked]:bg-foreground"

  @doc """
  Switch (shadcn `Switch`) — an on/off switch matching Radix's DOM and ARIA
  (`role="switch"`, `aria-checked`, `data-state`) with a sliding thumb.
  Toggling runs client-side through `Phoenix.LiveView.JS` commands, so no
  server round trip is needed. When `name` is given it also renders a hidden
  `<input type="checkbox">` so the value submits with a form.

  ## Sizes

  `:default`, `:sm`
  """
  attr(:id, :string, required: true, doc: "stable, unique DOM id (the toggle JS needs it)")
  attr(:name, :string, default: nil, doc: "renders a hidden input for form submission when given")
  attr(:value, :string, default: "on", doc: "submitted value")
  attr(:size, :atom, default: :default, values: [:default, :sm], doc: "switch size")
  attr(:checked, :boolean, default: false, doc: "initial checked state")
  attr(:disabled, :boolean, default: false, doc: "disables the switch")
  attr(:required, :boolean, default: false, doc: "marks the switch required")
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)

  def switch(assigns) do
    assigns =
      assign(assigns,
        classes: switch_classes(assigns),
        thumb_classes: @switch_thumb_classes
      )

    ~H"""
    <button
      type="button"
      role="switch"
      id={@id}
      aria-checked={to_string(@checked)}
      aria-required={@required && "true"}
      data-state={if @checked, do: "checked", else: "unchecked"}
      data-disabled={@disabled && ""}
      data-size={@size}
      disabled={@disabled}
      value={@value}
      class={@classes}
      data-slot="switch"
      phx-click={if @disabled, do: nil, else: switch_toggle_js(@id)}
      {@rest}
    >
      <span data-slot="switch-thumb" data-state={if @checked, do: "checked", else: "unchecked"} class={@thumb_classes}></span>
    </button>
    <input
      :if={@name}
      id={"#{@id}-input"}
      type="checkbox"
      aria-hidden="true"
      tabindex="-1"
      name={@name}
      value={@value}
      checked={@checked}
      required={@required}
      disabled={@disabled}
      class="absolute pointer-events-none opacity-0 m-0 -translate-x-full"
    />
    """
  end

  defp switch_classes(assigns) do
    [@switch_base, assigns[:class]]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp switch_toggle_js(id) do
    input = "##{Phoenix.HTML.css_escape("#{id}-input")}"

    %JS{}
    |> JS.toggle_attribute({"aria-checked", "true", "false"})
    |> JS.toggle_attribute({"data-state", "checked", "unchecked"})
    |> JS.toggle_attribute({"data-state", "checked", "unchecked"},
      to: {:inner, "[data-slot=switch-thumb]"}
    )
    |> JS.toggle_attribute({"checked", "checked"}, to: input)
    |> JS.dispatch("change", to: input)
  end

  @doc """
  Collapsible (shadcn `Collapsible`) — a trigger button that toggles a single
  collapsible content region. Toggling runs client-side through
  `Phoenix.LiveView.JS` commands, so no server round trip is needed. ARIA
  matches Radix: the trigger carries `aria-expanded` and `aria-controls`, and
  the content carries `data-state` and is `hidden` while closed.
  """
  attr(:id, :string, required: true)
  attr(:default_open, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot :trigger do
    attr(:disabled, :boolean)
  end

  slot(:content)

  def collapsible(assigns) do
    trigger_disabled =
      case assigns[:trigger] do
        [%{disabled: disabled} | _] -> disabled || false
        _ -> false
      end

    assigns =
      assign(assigns,
        open: assigns[:default_open] || false,
        trigger_disabled: trigger_disabled
      )

    ~H"""
    <div
      id={@id}
      data-slot="collapsible"
      data-state={if @open, do: "open", else: "closed"}
      class={@class}
      {@rest}
    >
      <button
        type="button"
        id={"#{@id}-trigger"}
        aria-controls={if @open, do: "#{@id}-content"}
        aria-expanded={to_string(@open)}
        data-slot="collapsible-trigger"
        data-state={if @open, do: "open", else: "closed"}
        data-disabled={@trigger_disabled && ""}
        disabled={@trigger_disabled}
        phx-click={if @trigger_disabled, do: nil, else: collapsible_toggle_js(@id)}
      >
        {render_slot(@trigger)}
      </button>
      <div
        id={"#{@id}-content"}
        data-slot="collapsible-content"
        data-state={if @open, do: "open", else: "closed"}
        hidden={not @open}
      >
        {render_slot(@content)}
      </div>
    </div>
    """
  end

  defp collapsible_toggle_js(id) do
    root = "##{Phoenix.HTML.css_escape(id)}"
    trigger = "##{Phoenix.HTML.css_escape("#{id}-trigger")}"
    content = "##{Phoenix.HTML.css_escape("#{id}-content")}"

    %JS{}
    |> JS.toggle_attribute({"aria-expanded", "true", "false"}, to: trigger)
    |> JS.toggle_attribute({"data-state", "open", "closed"}, to: trigger)
    |> JS.toggle_attribute({"data-state", "open", "closed"}, to: root)
    |> JS.toggle_attribute({"data-state", "open", "closed"}, to: content)
    |> JS.toggle_attribute({"hidden", "hidden"}, to: content)
  end

  @pagination_button_base "inline-flex items-center justify-center gap-1 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 shrink-0 outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"

  @doc """
  Pagination (shadcn `Pagination`) — pagination controls. Compose
  `pagination_content/1` (the `<ul>`), `pagination_item/1` (one `<li>` per
  control), `pagination_link/1` for page numbers, `pagination_previous/1`,
  `pagination_next/1` and `pagination_ellipsis/1`.
  """
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def pagination(assigns) do
    assigns =
      assign(assigns, :classes, part_classes("mx-auto flex w-full justify-center", assigns))

    ~H"""
    <nav role="navigation" aria-label="pagination" class={@classes} data-slot="pagination" {@rest}>
      {render_slot(@inner_block)}
    </nav>
    """
  end

  @doc "Pagination content (shadcn `PaginationContent`) — the `<ul>` of controls."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def pagination_content(assigns) do
    assigns = assign(assigns, :classes, part_classes("flex flex-row items-center gap-1", assigns))

    ~H"""
    <ul class={@classes} data-slot="pagination-content" {@rest}>
      {render_slot(@inner_block)}
    </ul>
    """
  end

  @doc "Pagination item (shadcn `PaginationItem`) — one `<li>` control."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def pagination_item(assigns) do
    ~H"""
    <li class={@class} data-slot="pagination-item" {@rest}>
      {render_slot(@inner_block)}
    </li>
    """
  end

  @doc "Pagination link (shadcn `PaginationLink`) — a page number."
  attr(:href, :string, default: nil)
  attr(:is_active, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def pagination_link(assigns) do
    assigns = assign(assigns, :classes, pagination_link_classes(assigns))

    ~H"""
    <a
      href={@href}
      aria-current={@is_active && "page"}
      data-active={@is_active && ""}
      class={@classes}
      data-slot="pagination-link"
      {@rest}
    >
      {render_slot(@inner_block)}
    </a>
    """
  end

  @doc "Pagination previous (shadcn `PaginationPrevious`)."
  attr(:href, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def pagination_previous(assigns) do
    assigns = assign(assigns, :classes, pagination_arrow_classes(assigns, "sm:pl-2.5"))

    ~H"""
    <a href={@href} aria-label="Go to previous page" class={@classes} data-slot="pagination-link" {@rest}>
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="m15 18-6-6 6-6" />
      </svg>
      <span class="hidden sm:block">Previous</span>
    </a>
    """
  end

  @doc "Pagination next (shadcn `PaginationNext`)."
  attr(:href, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def pagination_next(assigns) do
    assigns = assign(assigns, :classes, pagination_arrow_classes(assigns, "sm:pr-2.5"))

    ~H"""
    <a href={@href} aria-label="Go to next page" class={@classes} data-slot="pagination-link" {@rest}>
      <span class="hidden sm:block">Next</span>
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="m9 18 6-6-6-6" />
      </svg>
    </a>
    """
  end

  @doc "Pagination ellipsis (shadcn `PaginationEllipsis`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def pagination_ellipsis(assigns) do
    assigns =
      assign(assigns, :classes, part_classes("flex size-9 items-center justify-center", assigns))

    ~H"""
    <span aria-hidden="true" class={@classes} data-slot="pagination-ellipsis" {@rest}>
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="size-4">
        <circle cx="12" cy="12" r="1" />
        <circle cx="19" cy="12" r="1" />
        <circle cx="5" cy="12" r="1" />
      </svg>
      <span class="sr-only">More pages</span>
    </span>
    """
  end

  defp pagination_link_classes(assigns) do
    variant = if assigns[:is_active], do: :outline, else: :ghost

    [
      @button_base,
      @button_variants[variant],
      @button_sizes[:icon],
      assigns[:class]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp pagination_arrow_classes(assigns, side_padding) do
    [
      @pagination_button_base,
      @button_variants[:ghost],
      "h-9 py-2 has-[>svg]:px-3 px-2.5",
      side_padding,
      assigns[:class]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @radio_item_classes "aspect-square size-4 shrink-0 rounded-full border border-input text-primary shadow-xs transition-[color,box-shadow] outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:bg-input/30 dark:aria-invalid:ring-destructive/40"

  @doc """
  Radio group (shadcn `RadioGroup`) — a `role="radiogroup"` of button-based
  radio items with a checked indicator. Selection runs client-side through
  `Phoenix.LiveView.JS` commands; arrow keys move and select through the
  `UrUiRadioGroup` hook (from `UrUiHooks`, see USAGE.md).

  Each `:item` slot carries a `value` (and optionally `disabled`) and its
  content is used as the item's label. When `name` is given a hidden
  `<input type="radio">` is rendered per item so the value submits with a form.
  """
  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:default_value, :string, default: nil)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot :item do
    attr(:value, :string, required: true)
    attr(:disabled, :boolean)
  end

  def radio_group(assigns) do
    items = assigns[:item] || []
    group_disabled = assigns[:disabled] || false
    selected = radio_group_selected(items, assigns[:default_value], group_disabled)

    items =
      items
      |> Enum.with_index()
      |> Enum.map(fn {item, index} ->
        item
        |> Map.put(:index, index)
        |> Map.put(:id, "#{assigns.id}-item-#{index}")
        |> Map.put(:disabled, item[:disabled] || group_disabled)
        |> Map.put(:checked, item[:value] == selected)
      end)

    assigns =
      assign(assigns,
        items: items,
        classes: part_classes("grid gap-3", assigns),
        item_classes: @radio_item_classes
      )

    ~H"""
    <div
      id={@id}
      role="radiogroup"
      data-slot="radio-group"
      data-disabled={@disabled && ""}
      class={@classes}
      phx-hook="UrUiRadioGroup"
      {@rest}
    >
      <div :for={item <- @items} class="flex items-center gap-2">
        <button
          type="button"
          role="radio"
          id={item.id}
          value={item.value}
          aria-checked={to_string(item.checked)}
          data-state={if item.checked, do: "checked", else: "unchecked"}
          data-disabled={item.disabled && ""}
          disabled={item.disabled}
          tabindex={if item.checked, do: "0", else: "-1"}
          data-slot="radio-group-item"
          class={@item_classes}
          phx-click={if item.disabled, do: nil, else: radio_group_select_js(@items, item.index)}
        >
          <span
            data-slot="radio-group-indicator"
            data-state={if item.checked, do: "checked", else: "unchecked"}
            data-disabled={item.disabled && ""}
            hidden={not item.checked}
            class="relative flex items-center justify-center"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              class="absolute top-1/2 left-1/2 size-2 -translate-x-1/2 -translate-y-1/2 fill-primary"
              aria-hidden="true"
            >
              <circle cx="12" cy="12" r="10" />
            </svg>
          </span>
        </button>
        <label
          for={item.id}
          class="flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50"
        >{render_slot(item)}</label>
      </div>
      <input
        :if={@name}
        :for={item <- @items}
        id={"#{item.id}-input"}
        type="radio"
        aria-hidden="true"
        tabindex="-1"
        name={@name}
        value={item.value}
        checked={item.checked}
        disabled={item.disabled}
        class="absolute pointer-events-none opacity-0 m-0 -translate-x-full"
      />
    </div>
    """
  end

  defp radio_group_selected(items, default_value, group_disabled) do
    values =
      items
      |> Enum.reject(&(&1[:disabled] || group_disabled))
      |> Enum.map(& &1.value)

    cond do
      default_value in values -> default_value
      values == [] -> nil
      true -> hd(values)
    end
  end

  defp radio_group_select_js(items, selected_index) do
    Enum.reduce(items, %JS{}, fn item, js ->
      checked = item.index == selected_index
      target = "##{Phoenix.HTML.css_escape(item.id)}"
      indicator = "#{target} [data-slot=radio-group-indicator]"
      input = "##{Phoenix.HTML.css_escape("#{item.id}-input")}"
      state = if(checked, do: "checked", else: "unchecked")

      js =
        js
        |> JS.set_attribute({"aria-checked", to_string(checked)}, to: target)
        |> JS.set_attribute({"data-state", state}, to: target)
        |> JS.set_attribute({"tabindex", if(checked, do: "0", else: "-1")}, to: target)
        |> JS.set_attribute({"data-state", state}, to: indicator)

      js =
        if checked do
          js
          |> JS.remove_attribute("hidden", to: indicator)
          |> JS.set_attribute({"checked", "checked"}, to: input)
          |> JS.dispatch("change", to: input)
        else
          js
          |> JS.set_attribute({"hidden", "hidden"}, to: indicator)
          |> JS.remove_attribute("checked", to: input)
        end

      js
    end)
  end

  @doc """
  Badge (shadcn `Badge`) — a small status descriptor.

  ## Variants

  `:default`, `:secondary`, `:destructive`, `:outline`, `:ghost`, `:link`
  """
  attr(:variant, :atom,
    default: :default,
    values: [:default, :secondary, :destructive, :outline, :ghost, :link],
    doc: "visual variant"
  )

  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def badge(assigns) do
    assigns = assign(assigns, :classes, badge_classes(assigns))

    ~H"""
    <span class={@classes} data-slot="badge" data-variant={@variant} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  defp badge_classes(assigns) do
    [@badge_base, @badge_variants[assigns.variant], assigns[:class]]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Kbd (shadcn `Kbd`) — a keyboard key or key combination.

  Group several keys in a `kbd_group/1`. For a combination, put the individual
  keys inside the group; a single key can be rendered on its own.
  """
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def kbd(assigns) do
    assigns = assign(assigns, :classes, part_classes(kbd_classes(), assigns))

    ~H"""
    <kbd class={@classes} data-slot="kbd" {@rest}>
      {render_slot(@inner_block)}
    </kbd>
    """
  end

  @doc """
  Kbd group (shadcn `KbdGroup`) — a key combination.
  """
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def kbd_group(assigns) do
    assigns = assign(assigns, :classes, part_classes("inline-flex items-center gap-1", assigns))

    ~H"""
    <kbd class={@classes} data-slot="kbd-group" {@rest}>
      {render_slot(@inner_block)}
    </kbd>
    """
  end

  defp kbd_classes do
    "pointer-events-none inline-flex h-5 w-fit min-w-5 items-center justify-center gap-1 rounded-sm bg-muted px-1 font-sans text-xs font-medium text-muted-foreground select-none [&_svg:not([class*='size-'])]:size-3 [[data-slot=tooltip-content]_&]:bg-background/20 [[data-slot=tooltip-content]_&]:text-background dark:[[data-slot=tooltip-content]_&]:bg-background/10"
  end

  @doc """
  Spinner (shadcn `Spinner`) — an accessible loading indicator. It is a lucide
  loader icon sized `size-4` and animated with `animate-spin`, with
  `role="status"` and `aria-label="Loading"`. Size it up/down through `class`.
  """
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)

  def spinner(assigns) do
    assigns = assign(assigns, :classes, part_classes("size-4 animate-spin", assigns))

    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      role="status"
      aria-label="Loading"
      class={@classes}
      data-slot="spinner"
      {@rest}
    >
      <path d="M21 12a9 9 0 1 1-6.219-8.56" />
    </svg>
    """
  end

  @doc """
  Progress (shadcn `Progress`) — a determinate progress bar. The fill position
  is set by the `UrUiProgress` hook (from `UrUiHooks`, see USAGE.md), which
  applies the translate transform through the CSSOM to keep the markup free of
  inline styles under a strict Content-Security-Policy. `id` is required: the
  hook needs a stable DOM id.
  """
  attr(:id, :string, required: true, doc: "stable, unique DOM id (the hook needs it)")
  attr(:value, :integer, default: 0, doc: "completion value")
  attr(:max, :integer, default: 100, doc: "maximum value")
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)

  def progress(assigns) do
    assigns =
      assign(assigns,
        classes:
          part_classes("relative h-2 w-full overflow-hidden rounded-full bg-primary/20", assigns),
        state: progress_state(assigns[:value], assigns[:max]),
        label: "#{round(assigns[:value] / assigns[:max] * 100)}%"
      )

    ~H"""
    <div
      id={@id}
      role="progressbar"
      aria-valuemax={@max}
      aria-valuemin="0"
      aria-valuenow={@value}
      aria-valuetext={@label}
      data-state={@state}
      data-value={@value}
      data-max={@max}
      data-slot="progress"
      class={@classes}
      {@rest}
    >
      <div
        id={"#{@id}-indicator"}
        data-slot="progress-indicator"
        data-state={@state}
        data-value={@value}
        data-max={@max}
        class="h-full w-full flex-1 bg-primary transition-all"
        phx-hook="UrUiProgress"
      >
      </div>
    </div>
    """
  end

  defp progress_state(value, max) when value == max, do: "complete"
  defp progress_state(_value, _max), do: "loading"

  @doc """
  Aspect ratio (shadcn `AspectRatio`) — a wrapper that holds its content at a
  fixed width/height ratio and, like Radix, positions the content absolutely
  so it cannot stretch the frame. `ratio` is a `"width/height"` string: the
  common `"1/1"`, `"16/9"`, `"4/3"` and `"3/4"` map to Tailwind aspect
  utilities; other ratios are not generated, so width and ratio come from
  `class` (e.g. `class: "aspect-[5/4] w-64"`) or a sized container.
  """
  attr(:ratio, :string, default: "1/1", doc: "aspect ratio as \"width/height\"")
  attr(:class, :string, default: nil, doc: "extra classes appended to the frame")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def aspect_ratio(assigns) do
    assigns =
      assign(assigns,
        classes:
          ["relative w-full", aspect_ratio_class(assigns[:ratio]), assigns[:class]]
          |> Enum.reject(&is_nil/1)
          |> Enum.join(" ")
      )

    ~H"""
    <div class={@classes}>
      <div class="absolute inset-0" data-slot="aspect-ratio" {@rest}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp aspect_ratio_class("1/1"), do: "aspect-square"
  defp aspect_ratio_class("16/9"), do: "aspect-video"
  defp aspect_ratio_class("4/3"), do: "aspect-[4/3]"
  defp aspect_ratio_class("3/4"), do: "aspect-[3/4]"
  defp aspect_ratio_class(_ratio), do: nil

  @field_orientations %{
    vertical: "flex-col [&>*]:w-full [&>.sr-only]:w-auto",
    horizontal:
      "flex-row items-center [&>[data-slot=field-label]]:flex-auto has-[>[data-slot=field-content]]:items-start has-[>[data-slot=field-content]]:[&>[role=checkbox],[role=radio]]:mt-px",
    responsive:
      "flex-col @md/field-group:flex-row @md/field-group:items-center [&>*]:w-full @md/field-group:[&>*]:w-auto [&>.sr-only]:w-auto @md/field-group:[&>[data-slot=field-label]]:flex-auto @md/field-group:has-[>[data-slot=field-content]]:items-start @md/field-group:has-[>[data-slot=field-content]]:[&>[role=checkbox],[role=radio]]:mt-px"
  }

  @doc """
  Field (shadcn `Field`) — labelled form-field shells. Compose `field_set/1`,
  `field_legend/1`, `field_group/1`, `field/1`, `field_content/1`,
  `field_label/1`, `field_title/1`, `field_description/1`, `field_separator/1`
  and `field_error/1` to wrap form controls with labels and errors.
  """
  attr(:orientation, :atom,
    default: :vertical,
    values: [:vertical, :horizontal, :responsive]
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def field(assigns) do
    assigns =
      assign(assigns,
        classes:
          [
            "group/field flex w-full gap-3 data-[invalid=true]:text-destructive",
            @field_orientations[assigns[:orientation] || :vertical],
            assigns[:class]
          ]
          |> Enum.reject(&is_nil/1)
          |> Enum.join(" ")
      )

    ~H"""
    <div role="group" data-slot="field" data-orientation={@orientation} class={@classes} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Field set (shadcn `FieldSet`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def field_set(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "flex flex-col gap-6 has-[>[data-slot=checkbox-group]]:gap-3 has-[>[data-slot=radio-group]]:gap-3",
          assigns
        )
      )

    ~H"""
    <fieldset class={@classes} data-slot="field-set" {@rest}>
      {render_slot(@inner_block)}
    </fieldset>
    """
  end

  @doc "Field legend (shadcn `FieldLegend`)."
  attr(:variant, :atom, default: :legend, values: [:legend, :label])
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def field_legend(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "mb-3 font-medium data-[variant=legend]:text-base data-[variant=label]:text-sm",
          assigns
        )
      )

    ~H"""
    <legend class={@classes} data-slot="field-legend" data-variant={@variant} {@rest}>
      {render_slot(@inner_block)}
    </legend>
    """
  end

  @doc "Field group (shadcn `FieldGroup`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def field_group(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "group/field-group @container/field-group flex w-full flex-col gap-7 data-[slot=checkbox-group]:gap-3 [&>[data-slot=field-group]]:gap-4",
          assigns
        )
      )

    ~H"""
    <div class={@classes} data-slot="field-group" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Field content (shadcn `FieldContent`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def field_content(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes("group/field-content flex flex-1 flex-col gap-1.5 leading-snug", assigns)
      )

    ~H"""
    <div class={@classes} data-slot="field-content" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Field label (shadcn `FieldLabel`)."
  attr(:for, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def field_label(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "group/field-label peer/field-label flex w-fit gap-2 leading-snug group-data-[disabled=true]/field:opacity-50 has-[>[data-slot=field]]:w-full has-[>[data-slot=field]]:flex-col has-[>[data-slot=field]]:rounded-md has-[>[data-slot=field]]:border [&>*]:data-[slot=field]:p-4 has-data-[state=checked]:border-primary has-data-[state=checked]:bg-primary/5 dark:has-data-[state=checked]:bg-primary/10",
          assigns
        )
      )

    ~H"""
    <label for={@for} class={@classes} data-slot="field-label" {@rest}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc "Field title (shadcn `FieldTitle`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def field_title(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "flex w-fit items-center gap-2 text-sm leading-snug font-medium group-data-[disabled=true]/field:opacity-50",
          assigns
        )
      )

    ~H"""
    <div class={@classes} data-slot="field-label" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Field description (shadcn `FieldDescription`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def field_description(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "text-sm leading-normal font-normal text-muted-foreground group-has-[[data-orientation=horizontal]]/field:text-balance last:mt-0 nth-last-2:-mt-1 [[data-variant=legend]+&]:-mt-1.5 [&>a]:underline [&>a]:underline-offset-4 [&>a:hover]:text-primary",
          assigns
        )
      )

    ~H"""
    <p class={@classes} data-slot="field-description" {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc "Field separator (shadcn `FieldSeparator`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def field_separator(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "relative -my-2 h-5 text-sm group-data-[variant=outline]/field-group:-mb-2",
          assigns
        )
      )

    ~H"""
    <div class={@classes} data-slot="field-separator" data-content={@inner_block != []} {@rest}>
      <div
        role="none"
        data-slot="separator"
        data-orientation="horizontal"
        class="bg-border shrink-0 data-[orientation=horizontal]:h-px data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-px absolute inset-0 top-1/2"
      >
      </div>
      <span :if={@inner_block != []} class="relative mx-auto block w-fit bg-background px-2 text-muted-foreground" data-slot="field-separator-content">
        {render_slot(@inner_block)}
      </span>
    </div>
    """
  end

  @doc """
  Field error (shadcn `FieldError`) — an `role="alert"` error message. Pass
  `errors` (a list of `{message, opts}` tuples or strings) or an `:inner_block`.
  """
  attr(:errors, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def field_error(assigns) do
    errors =
      case assigns[:errors] do
        nil -> []
        list when is_list(list) -> Enum.map(list, &field_error_message/1)
        other -> [other]
      end

    assigns = assign(assigns, errors: Enum.reject(errors, &is_nil/1))

    ~H"""
    <div
      :if={@inner_block != [] or @errors != []}
      role="alert"
      class={part_classes("text-sm font-normal text-destructive", assigns)}
      data-slot="field-error"
      {@rest}
    >
      <ul :if={length(@errors) > 1} class="ml-4 flex list-disc flex-col gap-1">
        <li :for={error <- @errors}>{error}</li>
      </ul>
      <span :if={length(@errors) == 1}>{hd(@errors)}</span>
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp field_error_message({message, options}) do
    Enum.reduce(options, message, fn {key, value}, text ->
      String.replace(text, "%{#{key}}", to_string(value))
    end)
  end

  defp field_error_message(message) when is_binary(message), do: message
  defp field_error_message(_), do: nil

  @empty_media_variants %{
    default: "bg-transparent",
    icon:
      "flex size-10 shrink-0 items-center justify-center rounded-lg bg-muted text-foreground [&_svg:not([class*='size-'])]:size-6"
  }

  @doc """
  Empty (shadcn `Empty`) — an empty-state placeholder. Compose `empty_header/1`,
  `empty_media/1`, `empty_title/1`, `empty_description/1` and `empty_content/1`
  inside the root.
  """
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def empty(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "flex min-w-0 flex-1 flex-col items-center justify-center gap-6 rounded-lg border-dashed p-6 text-center text-balance md:p-12",
          assigns
        )
      )

    ~H"""
    <div class={@classes} data-slot="empty" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Empty header (shadcn `EmptyHeader`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def empty_header(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes("flex max-w-sm flex-col items-center gap-2 text-center", assigns)
      )

    ~H"""
    <div class={@classes} data-slot="empty-header" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Empty media (shadcn `EmptyMedia`)."
  attr(:variant, :atom, default: :default, values: [:default, :icon])
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def empty_media(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "mb-2 flex shrink-0 items-center justify-center [&_svg]:pointer-events-none [&_svg]:shrink-0 " <>
            @empty_media_variants[assigns[:variant] || :default],
          assigns
        )
      )

    ~H"""
    <div class={@classes} data-slot="empty-icon" data-variant={@variant} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Empty title (shadcn `EmptyTitle`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def empty_title(assigns) do
    assigns =
      assign(assigns, :classes, part_classes("text-lg font-medium tracking-tight", assigns))

    ~H"""
    <div class={@classes} data-slot="empty-title" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Empty description (shadcn `EmptyDescription`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def empty_description(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "text-sm/relaxed text-muted-foreground [&>a]:underline [&>a]:underline-offset-4 [&>a:hover]:text-primary",
          assigns
        )
      )

    ~H"""
    <div class={@classes} data-slot="empty-description" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Empty content (shadcn `EmptyContent`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def empty_content(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "flex w-full max-w-sm min-w-0 flex-col items-center gap-4 text-sm text-balance",
          assigns
        )
      )

    ~H"""
    <div class={@classes} data-slot="empty-content" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Breadcrumb (shadcn `Breadcrumb`) — a page-path breadcrumb. Compose the parts
  inside the root: `breadcrumb_list/1` (an `<ol>`), one `breadcrumb_item/1`
  per crumb, `breadcrumb_link/1` for links and `breadcrumb_page/1` for the
  current page. `breadcrumb_separator/1` and `breadcrumb_ellipsis/1` render the
  chevron and the collapsed ("More") placeholder, exactly as shadcn does.
  """
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def breadcrumb(assigns) do
    ~H"""
    <nav aria-label="breadcrumb" class={@class} data-slot="breadcrumb" {@rest}>
      {render_slot(@inner_block)}
    </nav>
    """
  end

  @doc "Breadcrumb list (shadcn `BreadcrumbList`) — the ordered list of crumbs."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def breadcrumb_list(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "flex flex-wrap items-center gap-1.5 text-sm break-words text-muted-foreground sm:gap-2.5",
          assigns
        )
      )

    ~H"""
    <ol class={@classes} data-slot="breadcrumb-list" {@rest}>
      {render_slot(@inner_block)}
    </ol>
    """
  end

  @doc "Breadcrumb item (shadcn `BreadcrumbItem`) — one crumb."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def breadcrumb_item(assigns) do
    assigns = assign(assigns, :classes, part_classes("inline-flex items-center gap-1.5", assigns))

    ~H"""
    <li class={@classes} data-slot="breadcrumb-item" {@rest}>
      {render_slot(@inner_block)}
    </li>
    """
  end

  @doc "Breadcrumb link (shadcn `BreadcrumbLink`) — a crumb that navigates."
  attr(:href, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def breadcrumb_link(assigns) do
    assigns =
      assign(assigns, :classes, part_classes("transition-colors hover:text-foreground", assigns))

    ~H"""
    <a href={@href} class={@classes} data-slot="breadcrumb-link" {@rest}>
      {render_slot(@inner_block)}
    </a>
    """
  end

  @doc "Breadcrumb page (shadcn `BreadcrumbPage`) — the current page."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def breadcrumb_page(assigns) do
    assigns = assign(assigns, :classes, part_classes("font-normal text-foreground", assigns))

    ~H"""
    <span
      class={@classes}
      data-slot="breadcrumb-page"
      role="link"
      aria-disabled="true"
      aria-current="page"
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc "Breadcrumb separator (shadcn `BreadcrumbSeparator`) — the chevron."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def breadcrumb_separator(assigns) do
    assigns = assign(assigns, :classes, part_classes("[&>svg]:size-3.5", assigns))

    ~H"""
    <li
      class={@classes}
      data-slot="breadcrumb-separator"
      role="presentation"
      aria-hidden="true"
      {@rest}
    >
      <%= if @inner_block == [] do %>
        {breadcrumb_chevron()}
      <% else %>
        {render_slot(@inner_block)}
      <% end %>
    </li>
    """
  end

  defp breadcrumb_chevron do
    Phoenix.HTML.raw(
      ~S(<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6" /></svg>)
    )
  end

  @doc "Breadcrumb ellipsis (shadcn `BreadcrumbEllipsis`) — the collapsed crumb."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def breadcrumb_ellipsis(assigns) do
    assigns =
      assign(assigns, :classes, part_classes("flex size-9 items-center justify-center", assigns))

    ~H"""
    <span
      class={@classes}
      data-slot="breadcrumb-ellipsis"
      role="presentation"
      aria-hidden="true"
      {@rest}
    >
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="size-4">
        <circle cx="12" cy="12" r="1" />
        <circle cx="19" cy="12" r="1" />
        <circle cx="5" cy="12" r="1" />
      </svg>
      <span class="sr-only">More</span>
    </span>
    """
  end

  @doc """
  Label (shadcn `Label`) — caption for a form field.
  """
  attr(:for, :string, default: nil, doc: "id of the labelled control")
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def label(assigns) do
    assigns = assign(assigns, :classes, label_classes(assigns))

    ~H"""
    <label for={@for} class={@classes} data-slot="label" {@rest}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  defp label_classes(assigns) do
    [
      "flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50",
      assigns[:class]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Separator (shadcn `Separator`) — visual or semantic divider.

  ARIA matches Radix: `decorative: true` (default) renders `role="none"`;
  `decorative: false` renders `role="separator"`, adding
  `aria-orientation="vertical"` for vertical separators (horizontal is the
  ARIA default, so it is omitted).
  """
  attr(:orientation, :atom,
    default: :horizontal,
    values: [:horizontal, :vertical],
    doc: "line direction"
  )

  attr(:decorative, :boolean,
    default: true,
    doc: "true = decoration only (role none)"
  )

  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)

  def separator(assigns) do
    assigns = assign(assigns, :classes, separator_classes(assigns))

    ~H"""
    <div
      class={@classes}
      data-slot="separator"
      data-orientation={@orientation}
      role={if @decorative, do: "none", else: "separator"}
      aria-orientation={if !@decorative and @orientation == :vertical, do: "vertical"}
      {@rest}
    >
    </div>
    """
  end

  defp separator_classes(assigns) do
    [
      "bg-border shrink-0 data-[orientation=horizontal]:h-px data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-px",
      assigns[:class]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Skeleton (shadcn `Skeleton`) — loading placeholder.

  Size and shape it through `class` (e.g. `class: "h-4 w-32"`).
  """
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)
  slot(:inner_block)

  def skeleton(assigns) do
    assigns = assign(assigns, :classes, skeleton_classes(assigns))

    ~H"""
    <div class={@classes} data-slot="skeleton" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp skeleton_classes(assigns) do
    ["bg-accent animate-pulse rounded-md", assigns[:class]]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Avatar (shadcn `Avatar`) — user image with fallback.

  Compose `avatar_image/1` and `avatar_fallback/1` inside the root;
  `avatar_badge/1`, `avatar_group/1` and `avatar_group_count/1` cover the
  accessory parts.

  ## Sizes

  `:default`, `:sm`, `:lg`
  """
  attr(:size, :atom, default: :default, values: [:default, :sm, :lg], doc: "avatar size")
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)
  slot(:inner_block)

  def avatar(assigns) do
    assigns = assign(assigns, :classes, avatar_classes(assigns))

    ~H"""
    <div class={@classes} data-slot="avatar" data-size={@size} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Avatar image (shadcn `AvatarImage`) — the user photo, inside `avatar/1`.

  As in Radix, the fallback is hidden once the image is shown, and the
  `UrUiAvatarImage` hook (from `UrUiHooks`, see USAGE.md) keeps the image
  hidden (fallback visible)
  while it loads and when it fails. Without the hook registered, the image
  shows and the fallback stays hidden. `id` is required: LiveView hooks need
  a DOM id that stays the same across renders.
  """
  attr(:id, :string, required: true, doc: "stable, unique DOM id (the hook needs it)")
  attr(:src, :string, default: nil, doc: "image URL")
  attr(:alt, :string, default: "", doc: "alternative text")
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)

  def avatar_image(assigns) do
    assigns = assign(assigns, :classes, part_classes("aspect-square size-full", assigns))

    ~H"""
    <img
      id={@id}
      src={@src}
      alt={@alt}
      class={@classes}
      data-slot="avatar-image"
      phx-hook="UrUiAvatarImage"
      {@rest}
    />
    """
  end

  @doc """
  Avatar fallback (shadcn `AvatarFallback`) — initials shown when the image
  is missing, inside `avatar/1`.
  """
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def avatar_fallback(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "flex size-full items-center justify-center rounded-full bg-muted text-sm text-muted-foreground group-data-[size=sm]/avatar:text-xs [[data-slot=avatar-image]:not([hidden])~&]:hidden",
          assigns
        )
      )

    ~H"""
    <span class={@classes} data-slot="avatar-fallback" {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc """
  Avatar badge (shadcn `AvatarBadge`) — status marker on the avatar corner.
  """
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def avatar_badge(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "absolute right-0 bottom-0 z-10 inline-flex items-center justify-center rounded-full bg-primary text-primary-foreground ring-2 ring-background select-none group-data-[size=sm]/avatar:size-2 group-data-[size=sm]/avatar:[&>svg]:hidden group-data-[size=default]/avatar:size-2.5 group-data-[size=default]/avatar:[&>svg]:size-2 group-data-[size=lg]/avatar:size-3 group-data-[size=lg]/avatar:[&>svg]:size-2",
          assigns
        )
      )

    ~H"""
    <span class={@classes} data-slot="avatar-badge" {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc """
  Avatar group (shadcn `AvatarGroup`) — overlapping avatars.
  """
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def avatar_group(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "group/avatar-group flex -space-x-2 *:data-[slot=avatar]:ring-2 *:data-[slot=avatar]:ring-background",
          assigns
        )
      )

    ~H"""
    <div class={@classes} data-slot="avatar-group" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Avatar group count (shadcn `AvatarGroupCount`) — the "+N" bubble in a group.
  """
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def avatar_group_count(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "relative flex size-8 shrink-0 items-center justify-center rounded-full bg-muted text-sm text-muted-foreground ring-2 ring-background group-has-data-[size=lg]/avatar-group:size-10 group-has-data-[size=sm]/avatar-group:size-6 [&>svg]:size-4 group-has-data-[size=lg]/avatar-group:[&>svg]:size-5 group-has-data-[size=sm]/avatar-group:[&>svg]:size-3",
          assigns
        )
      )

    ~H"""
    <div class={@classes} data-slot="avatar-group-count" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp avatar_classes(assigns) do
    [
      "group/avatar relative flex size-8 shrink-0 overflow-hidden rounded-full select-none data-[size=lg]:size-10 data-[size=sm]:size-6",
      assigns[:class]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc "Card surface with composable shadcn-compatible parts."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def card(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "bg-card text-card-foreground flex flex-col gap-6 rounded-xl border py-6 shadow-sm",
          assigns
        )
      )

    ~H"""
    <div class={@classes} data-slot="card" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Card header; reserves a trailing column when card_action is present."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def card_header(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "@container/card-header grid auto-rows-min grid-rows-[auto_auto] items-start gap-2 px-6 has-data-[slot=card-action]:grid-cols-[1fr_auto] [.border-b]:pb-6",
          assigns
        )
      )

    ~H"""
    <div class={@classes} data-slot="card-header" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Card heading."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def card_title(assigns) do
    assigns = assign(assigns, :classes, part_classes("leading-none font-semibold", assigns))

    ~H"""
    <div class={@classes} data-slot="card-title" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Supporting card copy."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def card_description(assigns) do
    assigns = assign(assigns, :classes, part_classes("text-muted-foreground text-sm", assigns))

    ~H"""
    <div class={@classes} data-slot="card-description" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Action placed at the trailing edge of card_header."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def card_action(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes("col-start-2 row-span-2 row-start-1 self-start justify-self-end", assigns)
      )

    ~H"""
    <div class={@classes} data-slot="card-action" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Main card body."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def card_content(assigns) do
    assigns = assign(assigns, :classes, part_classes("px-6", assigns))

    ~H"""
    <div class={@classes} data-slot="card-content" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Card footer for actions or metadata."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def card_footer(assigns) do
    assigns =
      assign(assigns, :classes, part_classes("flex items-center px-6 [.border-t]:pt-6", assigns))

    ~H"""
    <div class={@classes} data-slot="card-footer" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Status message with default and destructive variants."
  attr(:variant, :atom, values: [:default, :destructive], default: :default)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def alert(assigns) do
    assigns = assign(assigns, :classes, alert_classes(assigns))

    ~H"""
    <div
      role="alert"
      class={@classes}
      data-slot="alert"
      data-variant={@variant}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Alert heading."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def alert_title(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes("col-start-2 line-clamp-1 min-h-4 font-medium tracking-tight", assigns)
      )

    ~H"""
    <div class={@classes} data-slot="alert-title" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Alert supporting copy."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def alert_description(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "text-muted-foreground col-start-2 grid justify-items-start gap-1 text-sm [&_p]:leading-relaxed",
          assigns
        )
      )

    ~H"""
    <div class={@classes} data-slot="alert-description" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Responsive table wrapped in an overflow container."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def table(assigns) do
    assigns = assign(assigns, :classes, part_classes("w-full caption-bottom text-sm", assigns))

    ~H"""
    <div class="relative w-full overflow-x-auto" data-slot="table-container">
      <table class={@classes} data-slot="table" {@rest}>
        {render_slot(@inner_block)}
      </table>
    </div>
    """
  end

  @doc "Table heading rows."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def table_header(assigns) do
    assigns = assign(assigns, :classes, part_classes("[&_tr]:border-b", assigns))

    ~H"""
    <thead class={@classes} data-slot="table-header" {@rest}>
      {render_slot(@inner_block)}
    </thead>
    """
  end

  @doc "Table body rows."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def table_body(assigns) do
    assigns = assign(assigns, :classes, part_classes("[&_tr:last-child]:border-0", assigns))

    ~H"""
    <tbody class={@classes} data-slot="table-body" {@rest}>
      {render_slot(@inner_block)}
    </tbody>
    """
  end

  @doc "Table summary rows."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def table_footer(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes("bg-muted/50 border-t font-medium [&>tr]:last:border-b-0", assigns)
      )

    ~H"""
    <tfoot class={@classes} data-slot="table-footer" {@rest}>
      {render_slot(@inner_block)}
    </tfoot>
    """
  end

  @doc "Table row; pass data-state=selected through rest when selected."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def table_row(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "hover:bg-muted/50 data-[state=selected]:bg-muted border-b transition-colors",
          assigns
        )
      )

    ~H"""
    <tr class={@classes} data-slot="table-row" {@rest}>
      {render_slot(@inner_block)}
    </tr>
    """
  end

  @doc "Column heading cell."
  attr(:scope, :string, default: "col")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def table_head(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "text-foreground h-10 px-2 text-left align-middle font-medium whitespace-nowrap [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]",
          assigns
        )
      )

    ~H"""
    <th scope={@scope} class={@classes} data-slot="table-head" {@rest}>
      {render_slot(@inner_block)}
    </th>
    """
  end

  @doc "Table data cell."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def table_cell(assigns) do
    assigns =
      assign(
        assigns,
        :classes,
        part_classes(
          "p-2 align-middle whitespace-nowrap [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]",
          assigns
        )
      )

    ~H"""
    <td class={@classes} data-slot="table-cell" {@rest}>
      {render_slot(@inner_block)}
    </td>
    """
  end

  @doc "Accessible table caption."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def table_caption(assigns) do
    assigns =
      assign(assigns, :classes, part_classes("text-muted-foreground mt-4 text-sm", assigns))

    ~H"""
    <caption class={@classes} data-slot="table-caption" {@rest}>
      {render_slot(@inner_block)}
    </caption>
    """
  end

  @doc "Native input with Phoenix form-field and changeset-error support."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:type, :string, default: "text")
  attr(:errors, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def input(assigns) do
    field = assigns[:field]
    id = assigns[:id] || (field && field.id)
    name = assigns[:name] || (field && field.name)
    value = if assigns[:value] != nil, do: assigns[:value], else: field && field.value
    errors = assigns[:errors] || (field && field.errors) || []

    value =
      if assigns[:type] == "file",
        do: nil,
        else: Phoenix.HTML.Form.normalize_value(assigns[:type], value)

    assigns =
      assign(assigns,
        id: id,
        name: name,
        value: value,
        errors: errors,
        error_id: if(errors != [] and id, do: "#{id}-errors"),
        invalid: if(errors != [], do: "true"),
        classes: input_classes(assigns)
      )

    ~H"""
    <div data-slot="input-field">
      <input
        id={@id}
        name={@name}
        type={@type}
        value={@value}
        class={@classes}
        data-slot="input"
        data-invalid={@invalid}
        aria-invalid={@invalid}
        aria-describedby={@error_id}
        {@rest}
      />
      <div :if={@errors != []} id={@error_id} class="grid gap-1">
        <p :for={error <- @errors} class="text-destructive text-sm" data-slot="input-error">
          {input_error_message(error)}
        </p>
      </div>
    </div>
    """
  end

  defp input_classes(assigns) do
    [
      "file:text-foreground placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground dark:bg-input/30 border-input h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs transition-[color,box-shadow] outline-none file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
      assigns[:class]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp input_error_message({message, options}) do
    Enum.reduce(options, message, fn {key, value}, text ->
      String.replace(text, "%{#{key}}", to_string(value))
    end)
  end

  defp input_error_message(message) when is_binary(message), do: message

  @doc "Native textarea with Phoenix form-field and changeset-error support."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:errors, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def textarea(assigns) do
    field = assigns[:field]
    id = assigns[:id] || (field && field.id)
    name = assigns[:name] || (field && field.name)
    value = if assigns[:value] != nil, do: assigns[:value], else: field && field.value
    errors = assigns[:errors] || (field && field.errors) || []

    assigns =
      assign(assigns,
        id: id,
        name: name,
        value: value,
        errors: errors,
        error_id: if(errors != [] and id, do: "#{id}-errors"),
        invalid: if(errors != [], do: "true"),
        classes: textarea_classes(assigns)
      )

    ~H"""
    <div data-slot="textarea-field">
      <textarea
        id={@id}
        name={@name}
        class={@classes}
        data-slot="textarea"
        data-invalid={@invalid}
        aria-invalid={@invalid}
        aria-describedby={@error_id}
        {@rest}
      >{@value}</textarea>
      <div :if={@errors != []} id={@error_id} class="grid gap-1">
        <p :for={error <- @errors} class="text-destructive text-sm" data-slot="textarea-error">
          {input_error_message(error)}
        </p>
      </div>
    </div>
    """
  end

  defp textarea_classes(assigns) do
    [
      "flex field-sizing-content min-h-16 w-full rounded-md border border-input bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 md:text-sm dark:bg-input/30 dark:aria-invalid:ring-destructive/40",
      assigns[:class]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Checkbox (shadcn `Checkbox`) — a button-based checkbox matching Radix's DOM
  and ARIA. Toggling runs client-side through `Phoenix.LiveView.JS`, so no
  server round trip is needed. When `name` is given it also renders a hidden
  `<input type="checkbox">` (as Radix does) so the value submits with a form.

  As in Radix, Space toggles and Enter does not; the `UrUiCheckbox` hook (from
  `UrUiHooks`, see USAGE.md) prevents the native button's Enter click.
  """
  attr(:id, :string, required: true, doc: "stable, unique DOM id (the toggle JS needs it)")
  attr(:name, :string, default: nil, doc: "renders a hidden input for form submission when given")
  attr(:value, :string, default: "on", doc: "submitted value")
  attr(:checked, :boolean, default: false, doc: "initial checked state")
  attr(:disabled, :boolean, default: false, doc: "disables the checkbox")
  attr(:required, :boolean, default: false, doc: "marks the checkbox required")
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)

  def checkbox(assigns) do
    assigns = assign(assigns, :classes, checkbox_classes(assigns))

    ~H"""
    <button
      type="button"
      role="checkbox"
      id={@id}
      aria-checked={to_string(@checked)}
      aria-required={@required && "true"}
      data-state={if @checked, do: "checked", else: "unchecked"}
      data-disabled={@disabled && ""}
      disabled={@disabled}
      value={@value}
      class={@classes}
      data-slot="checkbox"
      phx-hook="UrUiCheckbox"
      phx-click={if @disabled, do: nil, else: checkbox_toggle_js(@id)}
      {@rest}
    >
      <span
        data-slot="checkbox-indicator"
        data-state={if @checked, do: "checked", else: "unchecked"}
        data-disabled={@disabled && ""}
        hidden={not @checked}
        class="grid place-content-center text-current transition-none pointer-events-none"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          class="size-3.5"
          aria-hidden="true"
        >
          <path d="M20 6 9 17l-5-5" />
        </svg>
      </span>
    </button>
    <input
      :if={@name}
      id={"#{@id}-input"}
      type="checkbox"
      aria-hidden="true"
      tabindex="-1"
      name={@name}
      value={@value}
      checked={@checked}
      required={@required}
      disabled={@disabled}
      class="absolute pointer-events-none opacity-0 m-0 -translate-x-full"
    />
    """
  end

  defp checkbox_classes(assigns) do
    [
      "peer size-4 shrink-0 rounded-[4px] border border-input shadow-xs transition-shadow outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 data-[state=checked]:border-primary data-[state=checked]:bg-primary data-[state=checked]:text-primary-foreground dark:bg-input/30 dark:aria-invalid:ring-destructive/40 dark:data-[state=checked]:bg-primary",
      assigns[:class]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp checkbox_toggle_js(id) do
    input = "##{Phoenix.HTML.css_escape("#{id}-input")}"

    %JS{}
    |> JS.toggle_attribute({"aria-checked", "true", "false"})
    |> JS.toggle_attribute({"data-state", "checked", "unchecked"})
    |> JS.toggle_attribute({"data-state", "checked", "unchecked"},
      to: {:inner, "[data-slot=checkbox-indicator]"}
    )
    |> JS.toggle_attribute({"hidden", "hidden"},
      to: {:inner, "[data-slot=checkbox-indicator]"}
    )
    |> JS.toggle_attribute({"checked", "checked"}, to: input)
    |> JS.dispatch("change", to: input)
  end

  @doc """
  Tabs (shadcn `Tabs`): a `tablist` of `<button role="tab">` triggers and one
  `tabpanel` per content slot.

  Selection runs on the client with `Phoenix.LiveView.JS` commands, so no
  server round trip is needed. Arrow Left/Right, Home and End move focus and
  selection between enabled tabs (wrapping, skipping disabled ones) through the
  `UrUiTabs` hook from ur_ui's JS module (`import {UrUiHooks} from "ur_ui"`,
  see USAGE.md). No inline script, so it works under a strict
  Content-Security-Policy.
  """
  attr(:id, :string, required: true)
  attr(:default_value, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot :trigger do
    attr(:value, :string, required: true)
    attr(:disabled, :boolean)
  end

  slot :content do
    attr(:value, :string, required: true)
  end

  def tabs(assigns) do
    assigns =
      assign(assigns,
        selected_value: tabs_selected_value(assigns),
        classes:
          part_classes("group/tabs flex gap-2 data-[orientation=horizontal]:flex-col", assigns)
      )

    ~H"""
    <div id={@id} class={@classes} data-slot="tabs" data-orientation="horizontal" {@rest}>
      <div
        id={"#{@id}-list"}
        role="tablist"
        aria-orientation="horizontal"
        class={tabs_list_classes()}
        data-slot="tabs-list"
        data-variant="default"
        data-orientation="horizontal"
        phx-hook="UrUiTabs"
      >
        <button
          :for={{trigger, index} <- Enum.with_index(@trigger)}
          type="button"
          role="tab"
          id={tabs_trigger_id(@id, index)}
          aria-selected={to_string(trigger.value == @selected_value)}
          aria-controls={tabs_panel_id(@id, tabs_content_index(@content, trigger.value))}
          tabindex={if(trigger.value == @selected_value, do: "0", else: "-1")}
          disabled={trigger[:disabled]}
          data-disabled={trigger[:disabled] && ""}
          data-state={if(trigger.value == @selected_value, do: "active", else: "inactive")}
          data-orientation="horizontal"
          data-slot="tabs-trigger"
          class={tabs_trigger_classes()}
          phx-click={tabs_select_js(@id, @trigger, @content, trigger.value)}
        >
          {render_slot(trigger)}
        </button>
      </div>
      <div
        :for={{content, index} <- Enum.with_index(@content)}
        id={tabs_panel_id(@id, index)}
        role="tabpanel"
        aria-labelledby={tabs_trigger_id(@id, tabs_trigger_index(@trigger, content.value))}
        tabindex="0"
        hidden={content.value != @selected_value}
        data-state={if(content.value == @selected_value, do: "active", else: "inactive")}
        data-orientation="horizontal"
        data-slot="tabs-content"
        class="flex-1 outline-none"
      >
        {render_slot(content)}
      </div>
    </div>
    """
  end

  # A trigger without matching content (or the reverse) gets no ARIA link.
  defp tabs_trigger_id(_id, nil), do: nil
  defp tabs_trigger_id(id, index), do: "#{id}-trigger-#{index}"
  defp tabs_panel_id(_id, nil), do: nil
  defp tabs_panel_id(id, index), do: "#{id}-panel-#{index}"

  defp tabs_trigger_index(triggers, value),
    do: Enum.find_index(triggers, &(&1.value == value))

  defp tabs_content_index(contents, value),
    do: Enum.find_index(contents, &(&1.value == value))

  defp tabs_list_classes do
    "group/tabs-list inline-flex w-fit items-center justify-center rounded-lg p-[3px] text-muted-foreground group-data-[orientation=horizontal]/tabs:h-9 group-data-[orientation=vertical]/tabs:h-fit group-data-[orientation=vertical]/tabs:flex-col data-[variant=line]:rounded-none bg-muted"
  end

  defp tabs_trigger_classes do
    [
      "relative inline-flex h-[calc(100%-1px)] flex-1 items-center justify-center gap-1.5 rounded-md border border-transparent px-2 py-1 text-sm font-medium whitespace-nowrap text-foreground/60 transition-all group-data-[orientation=vertical]/tabs:w-full group-data-[orientation=vertical]/tabs:justify-start hover:text-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:outline-1 focus-visible:outline-ring disabled:pointer-events-none disabled:opacity-50 group-data-[variant=default]/tabs-list:data-[state=active]:shadow-sm group-data-[variant=line]/tabs-list:data-[state=active]:shadow-none dark:text-muted-foreground dark:hover:text-foreground [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
      "group-data-[variant=line]/tabs-list:bg-transparent group-data-[variant=line]/tabs-list:data-[state=active]:bg-transparent dark:group-data-[variant=line]/tabs-list:data-[state=active]:border-transparent dark:group-data-[variant=line]/tabs-list:data-[state=active]:bg-transparent",
      "data-[state=active]:bg-background data-[state=active]:text-foreground dark:data-[state=active]:border-input dark:data-[state=active]:bg-input/30 dark:data-[state=active]:text-foreground",
      "after:absolute after:bg-foreground after:opacity-0 after:transition-opacity group-data-[orientation=horizontal]/tabs:after:inset-x-0 group-data-[orientation=horizontal]/tabs:after:bottom-[-5px] group-data-[orientation=horizontal]/tabs:after:h-0.5 group-data-[orientation=vertical]/tabs:after:inset-y-0 group-data-[orientation=vertical]/tabs:after:-right-1 group-data-[orientation=vertical]/tabs:after:w-0.5 group-data-[variant=line]/tabs-list:data-[state=active]:after:opacity-100"
    ]
    |> Enum.join(" ")
  end

  defp tabs_select_js(id, triggers, contents, selected_value) do
    js =
      triggers
      |> Enum.with_index()
      |> Enum.reduce(%JS{}, fn {trigger, index}, commands ->
        selected = trigger.value == selected_value
        target = "##{Phoenix.HTML.css_escape(tabs_trigger_id(id, index))}"

        commands
        |> JS.set_attribute({"aria-selected", to_string(selected)}, to: target)
        |> JS.set_attribute({"tabindex", if(selected, do: "0", else: "-1")}, to: target)
        |> JS.set_attribute({"data-state", if(selected, do: "active", else: "inactive")},
          to: target
        )
      end)

    contents
    |> Enum.with_index()
    |> Enum.reduce(js, fn {content, index}, commands ->
      selected = content.value == selected_value
      target = "##{Phoenix.HTML.css_escape(tabs_panel_id(id, index))}"

      commands =
        JS.set_attribute(commands, {"data-state", if(selected, do: "active", else: "inactive")},
          to: target
        )

      if selected do
        JS.remove_attribute(commands, "hidden", to: target)
      else
        JS.set_attribute(commands, {"hidden", "hidden"}, to: target)
      end
    end)
  end

  defp tabs_selected_value(assigns) do
    values = Enum.map(assigns[:trigger] || [], & &1.value)
    default = assigns[:default_value]
    if default in values, do: default, else: List.first(values)
  end

  @doc """
  Accessible accordion with matching trigger and content slots (shadcn `Accordion`).

  `type: :single` (the default) keeps at most one item open — opening an item
  closes the others; `type: :multiple` toggles every item independently.
  Opening and closing runs client-side through `Phoenix.LiveView.JS`; Enter
  and Space toggle an item through the native button.
  """
  attr(:id, :string, required: true)
  attr(:type, :atom, default: :single, values: [:single, :multiple])
  attr(:default_value, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot :trigger do
    attr(:value, :string, required: true)
    attr(:disabled, :boolean)
  end

  slot :content do
    attr(:value, :string, required: true)
  end

  def accordion(assigns) do
    rest =
      if assigns[:class],
        do: Map.put(assigns.rest, :class, assigns.class),
        else: assigns.rest

    assigns = assign(assigns, items: accordion_items(assigns), rest: rest)

    ~H"""
    <div id={@id} data-slot="accordion" {@rest}>
      <div
        :for={item <- @items}
        id={"#{@id}-item-#{item.index}"}
        class="border-b last:border-b-0"
        data-slot="accordion-item"
        data-state={if(item.open, do: "open", else: "closed")}
      >
        <h3 class="flex">
          <button
            type="button"
            id={"#{@id}-trigger-#{item.index}"}
            class="flex flex-1 items-start justify-between gap-4 rounded-md py-4 text-left text-sm font-medium transition-all outline-none hover:underline focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 [&[data-state=open]>svg]:rotate-180"
            aria-expanded={to_string(item.open)}
            aria-controls={"#{@id}-panel-#{item.index}"}
            data-slot="accordion-trigger"
            data-state={if(item.open, do: "open", else: "closed")}
            disabled={item.trigger[:disabled]}
            phx-click={if(item.trigger[:disabled], do: nil, else: item.toggle_js)}
          >
            {render_slot(item.trigger)}
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              class="pointer-events-none size-4 shrink-0 translate-y-0.5 text-muted-foreground transition-transform duration-200"
              aria-hidden="true"
            >
              <path d="m6 9 6 6 6-6" />
            </svg>
          </button>
        </h3>
        <div
          id={"#{@id}-panel-#{item.index}"}
          role="region"
          aria-labelledby={"#{@id}-trigger-#{item.index}"}
          class="overflow-hidden text-sm data-[state=closed]:animate-accordion-up data-[state=open]:animate-accordion-down"
          data-slot="accordion-content"
          data-state={if(item.open, do: "open", else: "closed")}
          hidden={not item.open}
        >
          <div class="pt-0 pb-4">
            {render_slot(item.content)}
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp accordion_items(assigns) do
    triggers = assigns[:trigger] || []
    contents = assigns[:content] || []
    open_values = assigns[:default_value] |> List.wrap() |> MapSet.new()
    type = assigns[:type] || :single

    triggers
    |> Enum.with_index()
    |> Enum.map(fn {trigger, index} ->
      %{
        trigger: trigger,
        index: index,
        content: Enum.find(contents, &(&1.value == trigger.value)) || empty_slot(),
        open: trigger.value in open_values,
        toggle_js: accordion_toggle_js(assigns.id, index, type, triggers)
      }
    end)
  end

  defp empty_slot, do: %{inner_block: fn _changed, _argument -> "" end}

  defp accordion_toggle_js(id, index, type, triggers) do
    target = fn kind, i -> "##{Phoenix.HTML.css_escape("#{id}-#{kind}-#{i}")}" end

    js =
      %JS{}
      |> JS.toggle_attribute({"aria-expanded", "true", "false"}, to: target.("trigger", index))
      |> JS.toggle_attribute({"data-state", "open", "closed"}, to: target.("trigger", index))
      |> JS.toggle_attribute({"data-state", "open", "closed"}, to: target.("item", index))
      |> JS.toggle_attribute({"data-state", "open", "closed"}, to: target.("panel", index))
      |> JS.toggle_attribute({"hidden", "hidden"}, to: target.("panel", index))

    if type == :single do
      triggers
      |> Enum.with_index()
      |> Enum.reduce(js, fn {_trigger, other}, commands ->
        if other == index do
          commands
        else
          commands
          |> JS.set_attribute({"aria-expanded", "false"}, to: target.("trigger", other))
          |> JS.set_attribute({"data-state", "closed"}, to: target.("trigger", other))
          |> JS.set_attribute({"data-state", "closed"}, to: target.("item", other))
          |> JS.set_attribute({"data-state", "closed"}, to: target.("panel", other))
          |> JS.set_attribute({"hidden", "hidden"}, to: target.("panel", other))
        end
      end)
    else
      js
    end
  end

  defp alert_classes(assigns) do
    variant =
      case assigns[:variant] || :default do
        :default ->
          "bg-card text-card-foreground"

        :destructive ->
          "text-destructive bg-card [&>svg]:text-current *:data-[slot=alert-description]:text-destructive/90"
      end

    [
      "relative w-full rounded-lg border px-4 py-3 text-sm grid has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr] grid-cols-[0_1fr] has-[>svg]:gap-x-3 gap-y-0.5 items-start [&>svg]:size-4 [&>svg]:translate-y-0.5 [&>svg]:text-current",
      variant,
      assigns[:class]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp part_classes(base, assigns) do
    [base, assigns[:class]]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end
end
