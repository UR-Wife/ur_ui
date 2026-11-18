# ur_ui usage

Shadcn-style components ported to Phoenix function components in the UR
black/red/white design. fam, Tongue Medicine and the agency can depend on
this library.

## Installation

Add to your `mix.exs`:

```elixir
{:ur_ui, github: "UR-Wife/ur_ui"}
```

## Styling

Serve `assets/ur_ui.css` (or copy it into your asset pipeline). It is the
single source of truth for the `--ur-wifes-*` design tokens; all component
classes reference tokens via `var(--ur-wifes-*)`. Never hardcode colors in
your own overrides — override the tokens instead.

## Conventions

- Components are plain function components in `UrUi.Components`.
- Variants and sizes are atoms (`variant: :destructive`, `size: :sm`).
- `class` is always accepted to extend, never replace, base classes.
- Missing optional attrs never crash; every attr has a default.
- Focus styling is outline-only, driven by `:focus-visible`.

## Components

Component entries are added as each component lands (batch 1: button,
badge, label, separator, skeleton, avatar, card, alert, table, input,
tabs, accordion).

### button

`UrUi.Components.button/1` — the primary action trigger (shadcn `Button`).

- `<.button>Save</.button>` for form submits and actions; prefer `type:`
  `:submit` inside forms.
- With `href` it renders an `<a>` instead (navigation, external links).
- Use `variant: :destructive` only for irreversible actions; `:ghost` and
  `:link` for low-emphasis actions (toolbars, inline actions).
- `:icon` sizes are square and expect a single icon as content.

Attr       | Type      | Default    | Notes
-----------|-----------|------------|------
`variant`  | atom      | `:default` | `:default`, `:destructive`, `:outline`, `:secondary`, `:ghost`, `:link`
`size`     | atom      | `:default` | `:default`, `:xs`, `:sm`, `:lg`, `:icon`, `:icon_xs`, `:icon_sm`, `:icon_lg`
`type`     | string    | `"button"` | ignored when `href` is given
`href`     | string    | `nil`      | renders `<a>` when given
`disabled` | boolean   | `false`    | `disabled` on `<button>`, `aria-disabled` on `<a>`
`class`    | string    | `nil`      | appended to base classes
`rest`     | global    | —          | `id`, `aria-*`, `phx-*`, `data-*` pass through
slot `:inner_block` | slot | required | button content

### badge

`UrUi.Components.badge/1` — small status descriptor (shadcn `Badge`).

- Use for counts, statuses and category tags; never as a button.
- `:destructive` for error/failed states, `:outline` for neutral tags,
  `:link` when the badge itself navigates.
- Keep content to one or two words.

Attr       | Type   | Default    | Notes
-----------|--------|------------|------
`variant`  | atom   | `:default` | `:default`, `:secondary`, `:destructive`, `:outline`, `:ghost`, `:link`
`class`    | string | `nil`      | appended to base classes
`rest`     | global | —          | `id`, `aria-*`, `phx-*`, `data-*` pass through
slot `:inner_block` | slot | required | badge content