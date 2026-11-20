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