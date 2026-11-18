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
end