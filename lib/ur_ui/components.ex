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
  @badge_base "inline-flex items-center justify-center rounded-md border px-2 py-0.5 text-xs font-medium w-fit whitespace-nowrap shrink-0 [&>svg]:size-3 gap-1 [&>svg]:pointer-events-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive transition-[color,box-shadow] overflow-hidden"
  @badge_variants %{
    default: "border-transparent bg-primary text-primary-foreground [a&]:hover:bg-primary/90",
    secondary:
      "border-transparent bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90",
    destructive:
      "border-transparent bg-destructive text-white [a&]:hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60",
    outline: "text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
    ghost:
      "border-transparent text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
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

  `decorative: true` (default) marks it as pure decoration
  (`role="none"`, hidden from the accessibility tree); `decorative: false`
  exposes it as `role="separator"` with `aria-orientation`.
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
      aria-hidden={if @decorative, do: "true", else: nil}
      aria-orientation={if @decorative, do: nil, else: @orientation}
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
  """
  attr(:src, :string, default: nil, doc: "image URL")
  attr(:alt, :string, default: "", doc: "alternative text")
  attr(:class, :string, default: nil, doc: "extra classes appended to base classes")
  attr(:rest, :global)

  def avatar_image(assigns) do
    assigns = assign(assigns, :classes, part_classes("aspect-square size-full", assigns))

    ~H"""
    <img src={@src} alt={@alt} class={@classes} data-slot="avatar-image" {@rest} />
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
          "bg-muted flex size-full items-center justify-center rounded-full text-sm group-data-[size=sm]/avatar:text-xs",
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
          "bg-primary text-primary-foreground ring-background absolute right-0 bottom-0 z-10 inline-flex items-center justify-center rounded-full ring-2 select-none group-data-[size=sm]/avatar:size-2 group-data-[size=sm]/avatar:[&>svg]:hidden group-data-[size=default]/avatar:size-2.5 group-data-[size=default]/avatar:[&>svg]:size-2 group-data-[size=lg]/avatar:size-3 group-data-[size=lg]/avatar:[&>svg]:size-2 [&>svg]:size-2.5",
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
          "[--avatar-group-spacing:0.5rem] group/avatar-group -space-x-[var(--avatar-group-spacing)] flex items-center [&_[data-slot=avatar]]:ring-background [&_[data-slot=avatar]]:ring-2",
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
          "bg-muted text-muted-foreground ring-background relative flex size-8 shrink-0 items-center justify-center rounded-full text-sm ring-2 group-has-data-[size=lg]/avatar-group:size-10 group-has-data-[size=sm]/avatar-group:size-6 [&>svg]:size-4 group-has-data-[size=lg]/avatar-group:[&>svg]:size-5 group-has-data-[size=sm]/avatar-group:[&>svg]:size-3",
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

  @doc """
  Tabs (shadcn `Tabs`): a `tablist` of `<button role="tab">` triggers and one
  `tabpanel` per content slot.

  Selection runs on the client with `Phoenix.LiveView.JS` commands, so no
  server round trip is needed. Arrow Left/Right, Home and End move focus and
  selection between enabled tabs (wrapping, skipping disabled ones) through the
  colocated `.Tabs` hook. It ships no inline script, so it works under a strict
  Content-Security-Policy; the host app imports ur_ui's colocated hooks once
  (see USAGE.md).
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
        phx-hook=".Tabs"
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
    <script :type={Phoenix.LiveView.ColocatedHook} name=".Tabs">
      // Roving focus with automatic activation, as in Radix Tabs: the next
      // enabled tab is focused and clicked, and its phx-click JS selects it.
      export default {
        mounted() {
          this.onKeyDown = (event) => {
            const tab = event.target.closest('[role="tab"]')
            if (!tab || tab.parentElement !== this.el) return
            const tabs = Array.from(this.el.children).filter(
              (el) => el.getAttribute("role") === "tab" && !el.disabled
            )
            const index = tabs.indexOf(tab)
            const count = tabs.length
            const next = {
              ArrowRight: (index + 1) % count,
              ArrowLeft: (index - 1 + count) % count,
              Home: 0,
              End: count - 1
            }[event.key]
            if (index < 0 || next === undefined) return
            event.preventDefault()
            tabs[next].focus()
            tabs[next].click()
          }
          this.el.addEventListener("keydown", this.onKeyDown)
        },
        destroyed() {
          this.el.removeEventListener("keydown", this.onKeyDown)
        }
      }
    </script>
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
