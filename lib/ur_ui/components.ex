defmodule UrUi.Components do
  @moduledoc """
  UR UI function components — shadcn structure and behaviour ported to
  Phoenix, styled by `assets/ur_ui.css` (`var(--ur-wifes-*)` tokens only).

  Conventions:

  - variants and sizes are atoms (`variant: :destructive`, `size: :sm`)
  - `class` extends, never replaces, the base classes
  - optional attrs have defaults; missing optional attrs never crash
  - global attributes (`id`, `aria-*`, `phx-*`, `data-*`) pass through
  - focus styling is outline-only (see the CSS)
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc """
  Button (shadcn `Button`).

  Renders a `<button>`; when `href` is given it renders an `<a>` instead
  (the shadcn `asChild` link use-case).

  ## Variants

  `:default`, `:destructive`, `:outline`, `:secondary`, `:ghost`, `:link`

  ## Sizes

  `:default`, `:xs`, `:sm`, `:lg`, `:icon`, `:icon_xs`, `:icon_sm`, `:icon_lg`
  """
  attr :variant, :atom,
    default: :default,
    values: [:default, :destructive, :outline, :secondary, :ghost, :link],
    doc: "visual variant"

  attr :size, :atom,
    default: :default,
    values: [:default, :xs, :sm, :lg, :icon, :icon_xs, :icon_sm, :icon_lg],
    doc: "size variant"

  attr :type, :string, default: "button", doc: "button type; ignored when href is given"
  attr :href, :string, default: nil, doc: "renders an <a> when given"
  attr :disabled, :boolean, default: false, doc: "disables the button"
  attr :class, :string, default: nil, doc: "extra classes appended to base classes"
  attr :rest, :global
  slot :inner_block, required: true

  def button(%{href: href} = assigns) when is_binary(href) do
    assigns = assign(assigns, :classes, button_classes(assigns))

    ~H"""
    <a href={@href} class={@classes} data-variant={@variant} data-size={@size} aria-disabled={@disabled} {@rest}>
      {render_slot(@inner_block)}
    </a>
    """
  end

  def button(assigns) do
    assigns = assign(assigns, :classes, button_classes(assigns))

    ~H"""
    <button type={@type} class={@classes} data-variant={@variant} data-size={@size} disabled={@disabled} {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp button_classes(assigns) do
    [
      "ur-btn",
      "ur-btn--#{assigns.variant}",
      "ur-btn--size-#{assigns.size}",
      assigns[:class]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Badge (shadcn `Badge`) — a small status descriptor.

  ## Variants

  `:default`, `:secondary`, `:destructive`, `:outline`, `:ghost`, `:link`
  """
  attr :variant, :atom,
    default: :default,
    values: [:default, :secondary, :destructive, :outline, :ghost, :link],
    doc: "visual variant"

  attr :class, :string, default: nil, doc: "extra classes appended to base classes"
  attr :rest, :global
  slot :inner_block, required: true

  def badge(assigns) do
    assigns = assign(assigns, :classes, badge_classes(assigns))

    ~H"""
    <span class={@classes} data-variant={@variant} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  defp badge_classes(assigns) do
    ["ur-badge", "ur-badge--#{assigns.variant}", assigns[:class]]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Label (shadcn `Label`) — caption for a form field.
  """
  attr :for, :string, default: nil, doc: "id of the labelled control"
  attr :class, :string, default: nil, doc: "extra classes appended to base classes"
  attr :rest, :global
  slot :inner_block, required: true

  def label(assigns) do
    assigns = assign(assigns, :classes, label_classes(assigns))

    ~H"""
    <label for={@for} class={@classes} {@rest}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  defp label_classes(assigns) do
    ["ur-label", assigns[:class]]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Separator (shadcn `Separator`) — visual or semantic divider.

  `decorative: true` (default) marks it as pure decoration
  (`role="none"`, hidden from the accessibility tree); `decorative: false`
  exposes it as `role="separator"` with `aria-orientation`.
  """
  attr :orientation, :atom,
    default: :horizontal,
    values: [:horizontal, :vertical],
    doc: "line direction"

  attr :decorative, :boolean,
    default: true,
    doc: "true = decoration only (role none)"

  attr :class, :string, default: nil, doc: "extra classes appended to base classes"
  attr :rest, :global

  def separator(assigns) do
    assigns = assign(assigns, :classes, separator_classes(assigns))

    ~H"""
    <div
      class={@classes}
      data-orientation={@orientation}
      role={if @decorative, do: "none", else: "separator"}
      aria-hidden={if @decorative, do: "true", else: nil}
      aria-orientation={if @decorative, do: nil, else: @orientation}
      {@rest}
    >
    </div>
    """
  end

  defp separator_classes(assigns) do
    ["ur-separator", "ur-separator--#{assigns.orientation}", assigns[:class]]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Skeleton (shadcn `Skeleton`) — loading placeholder.

  Size and shape it through `class` (e.g. `class: "h-4 w-32"`).
  """
  attr :class, :string, default: nil, doc: "extra classes appended to base classes"
  attr :rest, :global
  slot :inner_block

  def skeleton(assigns) do
    assigns = assign(assigns, :classes, skeleton_classes(assigns))

    ~H"""
    <div class={@classes} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp skeleton_classes(assigns) do
    ["ur-skeleton", assigns[:class]]
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
  attr :size, :atom, default: :default, values: [:default, :sm, :lg], doc: "avatar size"
  attr :class, :string, default: nil, doc: "extra classes appended to base classes"
  attr :rest, :global
  slot :inner_block

  def avatar(assigns) do
    assigns = assign(assigns, :classes, avatar_classes(assigns))

    ~H"""
    <div class={@classes} data-size={@size} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Avatar image (shadcn `AvatarImage`) — the user photo, inside `avatar/1`.
  """
  attr :src, :string, default: nil, doc: "image URL"
  attr :alt, :string, default: "", doc: "alternative text"
  attr :class, :string, default: nil, doc: "extra classes appended to base classes"
  attr :rest, :global

  def avatar_image(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-avatar__image", assigns))

    ~H"""
    <img src={@src} alt={@alt} class={@classes} {@rest} />
    """
  end

  @doc """
  Avatar fallback (shadcn `AvatarFallback`) — initials shown when the image
  is missing, inside `avatar/1`.
  """
  attr :class, :string, default: nil, doc: "extra classes appended to base classes"
  attr :rest, :global
  slot :inner_block, required: true

  def avatar_fallback(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-avatar__fallback", assigns))

    ~H"""
    <span class={@classes} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc """
  Avatar badge (shadcn `AvatarBadge`) — status marker on the avatar corner.
  """
  attr :class, :string, default: nil, doc: "extra classes appended to base classes"
  attr :rest, :global
  slot :inner_block, required: true

  def avatar_badge(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-avatar__badge", assigns))

    ~H"""
    <span class={@classes} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc """
  Avatar group (shadcn `AvatarGroup`) — overlapping avatars.
  """
  attr :class, :string, default: nil, doc: "extra classes appended to base classes"
  attr :rest, :global
  slot :inner_block, required: true

  def avatar_group(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-avatar-group", assigns))

    ~H"""
    <div class={@classes} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Avatar group count (shadcn `AvatarGroupCount`) — the "+N" bubble in a group.
  """
  attr :class, :string, default: nil, doc: "extra classes appended to base classes"
  attr :rest, :global
  slot :inner_block, required: true

  def avatar_group_count(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-avatar-group__count", assigns))

    ~H"""
    <div class={@classes} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp avatar_classes(assigns) do
    ["ur-avatar", "ur-avatar--size-#{assigns.size}", assigns[:class]]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc "Card surface with composable shadcn-compatible parts."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def card(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-card", assigns))

    ~H"""
    <div class={@classes} data-slot="card" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Card header; reserves a trailing column when card_action is present."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def card_header(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-card__header", assigns))

    ~H"""
    <div class={@classes} data-slot="card-header" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Card heading."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def card_title(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-card__title", assigns))

    ~H"""
    <div class={@classes} data-slot="card-title" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Supporting card copy."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def card_description(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-card__description", assigns))

    ~H"""
    <div class={@classes} data-slot="card-description" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Action placed at the trailing edge of card_header."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def card_action(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-card__action", assigns))

    ~H"""
    <div class={@classes} data-slot="card-action" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Main card body."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def card_content(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-card__content", assigns))

    ~H"""
    <div class={@classes} data-slot="card-content" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Card footer for actions or metadata."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def card_footer(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-card__footer", assigns))

    ~H"""
    <div class={@classes} data-slot="card-footer" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Status message with default and destructive variants."
  attr :variant, :atom, values: [:default, :destructive], default: :default
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

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
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def alert_title(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-alert__title", assigns))

    ~H"""
    <div class={@classes} data-slot="alert-title" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Alert supporting copy."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def alert_description(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-alert__description", assigns))

    ~H"""
    <div class={@classes} data-slot="alert-description" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Responsive table wrapped in an overflow container."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def table(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-table", assigns))

    ~H"""
    <div class="ur-table-container" data-slot="table-container">
      <table class={@classes} data-slot="table" {@rest}>
        {render_slot(@inner_block)}
      </table>
    </div>
    """
  end

  @doc "Table heading rows."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def table_header(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-table__header", assigns))

    ~H"""
    <thead class={@classes} data-slot="table-header" {@rest}>
      {render_slot(@inner_block)}
    </thead>
    """
  end

  @doc "Table body rows."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def table_body(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-table__body", assigns))

    ~H"""
    <tbody class={@classes} data-slot="table-body" {@rest}>
      {render_slot(@inner_block)}
    </tbody>
    """
  end

  @doc "Table summary rows."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def table_footer(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-table__footer", assigns))

    ~H"""
    <tfoot class={@classes} data-slot="table-footer" {@rest}>
      {render_slot(@inner_block)}
    </tfoot>
    """
  end

  @doc "Table row; pass data-state=selected through rest when selected."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def table_row(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-table__row", assigns))

    ~H"""
    <tr class={@classes} data-slot="table-row" {@rest}>
      {render_slot(@inner_block)}
    </tr>
    """
  end

  @doc "Column heading cell."
  attr :scope, :string, default: "col"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def table_head(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-table__head", assigns))

    ~H"""
    <th scope={@scope} class={@classes} data-slot="table-head" {@rest}>
      {render_slot(@inner_block)}
    </th>
    """
  end

  @doc "Table data cell."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def table_cell(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-table__cell", assigns))

    ~H"""
    <td class={@classes} data-slot="table-cell" {@rest}>
      {render_slot(@inner_block)}
    </td>
    """
  end

  @doc "Accessible table caption."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def table_caption(assigns) do
    assigns = assign(assigns, :classes, part_classes("ur-table__caption", assigns))

    ~H"""
    <caption class={@classes} data-slot="table-caption" {@rest}>
      {render_slot(@inner_block)}
    </caption>
    """
  end

  @doc "Native input with Phoenix form-field and changeset-error support."
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :any, default: nil
  attr :type, :string, default: "text"
  attr :errors, :any, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  def input(assigns) do
    field = assigns[:field]
    id = assigns[:id] || (field && field.id)
    name = assigns[:name] || (field && field.name)
    value = if assigns[:value] != nil, do: assigns[:value], else: field && field.value
    errors = assigns[:errors] || (field && field.errors) || []
    value = if assigns[:type] == "file", do: nil, else: Phoenix.HTML.Form.normalize_value(assigns[:type], value)

    assigns =
      assign(assigns,
        id: id,
        name: name,
        value: value,
        errors: errors,
        error_id: if(errors != [] and id, do: "#{id}-errors"),
        invalid: if(errors != [], do: "true"),
        classes: input_classes(assigns, errors)
      )

    ~H"""
    <div class="ur-input-field" data-slot="input-field">
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
      <div :if={@errors != []} id={@error_id} class="ur-input-errors">
        <p :for={error <- @errors} class="ur-input-error" data-slot="input-error">
          {input_error_message(error)}
        </p>
      </div>
    </div>
    """
  end

  defp input_classes(assigns, errors) do
    invalid = if errors != [], do: "ur-input--invalid"
    ["ur-input", invalid, assigns[:class]] |> Enum.reject(&is_nil/1) |> Enum.join(" ")
  end

  defp input_error_message({message, options}) do
    Enum.reduce(options, message, fn {key, value}, text ->
      String.replace(text, "%{#{key}}", to_string(value))
    end)
  end

  defp input_error_message(message) when is_binary(message), do: message

  @doc "Accessible tabs with matching trigger and content slots."
  attr :id, :string, required: true
  attr :default_value, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :trigger do
    attr :value, :string, required: true
    attr :disabled, :boolean
  end

  slot :content do
    attr :value, :string, required: true
  end

  def tabs(assigns) do
    assigns =
      assign(assigns,
        selected_value: tabs_selected_value(assigns),
        classes: part_classes("ur-tabs", assigns)
      )

    ~H"""
    <div id={@id} class={@classes} data-slot="tabs" {@rest}>
      <div class="ur-tabs__list" data-slot="tabs-list" role="tablist">
        <div
          :for={{trigger, index} <- Enum.with_index(@trigger)}
          id={"#{@id}-trigger-wrap-#{index}"}
          class="ur-tabs__trigger"
          data-state={if(trigger.value == @selected_value, do: "active", else: "inactive")}
        >
          <input
            id={"#{@id}-trigger-#{index}"}
            class="ur-tabs__input"
            type="radio"
            name={"#{@id}-values"}
            value={trigger.value}
            checked={trigger.value == @selected_value}
            disabled={trigger[:disabled]}
            role="tab"
            aria-selected={to_string(trigger.value == @selected_value)}
            aria-controls={"#{@id}-panel-#{index}"}
            aria-labelledby={"#{@id}-label-#{index}"}
            tabindex={if(trigger.value == @selected_value, do: 0, else: -1)}
            data-slot="tabs-trigger"
            data-state={if(trigger.value == @selected_value, do: "active", else: "inactive")}
            phx-change={tabs_select_js(@id, @trigger, @content, trigger.value)}
          />
          <label
            id={"#{@id}-label-#{index}"}
            for={"#{@id}-trigger-#{index}"}
            class="ur-tabs__label"
          >
            {render_slot(trigger)}
          </label>
        </div>
      </div>
      <div
        :for={{content, index} <- Enum.with_index(@content)}
        id={"#{@id}-panel-#{index}"}
        role="tabpanel"
        aria-labelledby={"#{@id}-trigger-#{index}"}
        aria-hidden={to_string(content.value != @selected_value)}
        hidden={content.value != @selected_value}
        class="ur-tabs__content"
        data-slot="tabs-content"
      >
        {render_slot(content)}
      </div>
    </div>
    """
  end

  defp tabs_select_js(id, triggers, contents, selected_value) do
    js = %JS{}

    js =
      triggers
      |> Enum.with_index()
      |> Enum.reduce(js, fn {trigger, index}, commands ->
        selected = trigger.value == selected_value
        target = "##{Phoenix.HTML.css_escape("#{id}-trigger-#{index}")}"
        wrap_target = "##{Phoenix.HTML.css_escape("#{id}-trigger-wrap-#{index}")}"
        state = if selected, do: "active", else: "inactive"

        commands
        |> JS.set_attribute({"aria-selected", to_string(selected)}, to: target)
        |> JS.set_attribute({"tabindex", if(selected, do: "0", else: "-1")}, to: target)
        |> JS.set_attribute({"data-state", state}, to: target)
        |> JS.set_attribute({"data-state", state}, to: wrap_target)
      end)

    contents
    |> Enum.with_index()
    |> Enum.reduce(js, fn {content, index}, commands ->
      selected = content.value == selected_value
      target = "##{Phoenix.HTML.css_escape("#{id}-panel-#{index}")}"
      state = if selected, do: "active", else: "inactive"

      commands = JS.set_attribute(commands, {"aria-hidden", to_string(!selected)}, to: target)
      commands = JS.set_attribute(commands, {"data-state", state}, to: target)

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
  attr :id, :string, required: true
  attr :type, :atom, default: :single, values: [:single, :multiple]
  attr :default_value, :any, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :trigger do
    attr :value, :string, required: true
    attr :disabled, :boolean
  end

  slot :content do
    attr :value, :string, required: true
  end

  def accordion(assigns) do
    assigns =
      assign(assigns,
        items: accordion_items(assigns),
        classes: part_classes("ur-accordion", assigns)
      )

    ~H"""
    <div id={@id} class={@classes} data-slot="accordion" {@rest}>
      <div
        :for={item <- @items}
        id={"#{@id}-item-#{item.index}"}
        class="ur-accordion__item"
        data-slot="accordion-item"
        data-state={if(item.open, do: "open", else: "closed")}
      >
        <h3 class="ur-accordion__header">
          <button
            type="button"
            id={"#{@id}-trigger-#{item.index}"}
            class="ur-accordion__trigger"
            aria-expanded={to_string(item.open)}
            aria-controls={"#{@id}-panel-#{item.index}"}
            data-slot="accordion-trigger"
            data-state={if(item.open, do: "open", else: "closed")}
            disabled={item.trigger[:disabled]}
            phx-click={if(item.trigger[:disabled], do: nil, else: item.toggle_js)}
          >
            {render_slot(item.trigger)}
          </button>
        </h3>
        <div
          id={"#{@id}-panel-#{item.index}"}
          role="region"
          aria-labelledby={"#{@id}-trigger-#{item.index}"}
          class="ur-accordion__content"
          data-slot="accordion-content"
          data-state={if(item.open, do: "open", else: "closed")}
          hidden={not item.open}
        >
          {render_slot(item.content)}
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
    variant = assigns[:variant] || :default
    ["ur-alert", "ur-alert--#{variant}", assigns[:class]] |> Enum.reject(&is_nil/1) |> Enum.join(" ")
  end

  defp part_classes(base, assigns) do
    [base, assigns[:class]]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end
end