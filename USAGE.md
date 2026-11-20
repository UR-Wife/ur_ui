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

### label

`UrUi.Components.label/1` — caption for a form field (shadcn `Label`).

- Always pair with a form control; pass `for:` pointing at the control id.
- Do not use as plain text — it is a form caption.

Attr   | Type   | Default | Notes
-------|--------|---------|------
`for`  | string | `nil`   | id of the labelled control
`class`| string | `nil`   | appended to base classes
`rest` | global | —       | `id`, `aria-*`, `phx-*`, `data-*` pass through
slot `:inner_block` | slot | required | label caption

### separator

`UrUi.Components.separator/1` — visual or semantic divider (shadcn `Separator`).

- Decorative by default: a horizontal rule between content sections.
- `decorative: false` when the separation is meaningful (e.g. a toolbar
  divider announced to screen readers) — then it exposes
  `role="separator"` with `aria-orientation`.

Attr          | Type    | Default       | Notes
--------------|---------|---------------|------
`orientation` | atom    | `:horizontal` | `:horizontal`, `:vertical`
`decorative`  | boolean | `true`        | `false` exposes role=separator
`class`       | string  | `nil`         | appended to base classes
`rest`        | global  | —             | `id`, `aria-*`, `phx-*`, `data-*` pass through

### skeleton

`UrUi.Components.skeleton/1` — loading placeholder (shadcn `Skeleton`).

- Show while content loads; mirror the shape of the content it replaces.
- Size it via `class` (`class: "h-4 w-32"`); it pulses via CSS keyframes.

Attr    | Type   | Default | Notes
--------|--------|---------|------
`class` | string | `nil`   | appended to base classes (sizing lives here)
`rest`  | global | —       | `id`, `aria-*`, `phx-*`, `data-*` pass through
slot `:inner_block` | slot | optional | rarely needed

### avatar

`UrUi.Components.avatar/1` — user image with fallback (shadcn `Avatar`).

- Compose: put `avatar_image/1` and `avatar_fallback/1` inside the root;
  the fallback (initials) shows when the image fails or is absent.
- `avatar_badge/1` for status markers, `avatar_group/1` +
  `avatar_group_count/1` for stacked teams.

Attr   | Type | Default    | Notes
-------|------|------------|------
`size` | atom | `:default` | `:default`, `:sm`, `:lg`
`class`| string | `nil`    | appended to base classes
`rest` | global | —        | `id`, `aria-*`, `phx-*`, `data-*` pass through
slot `:inner_block` | slot | optional | image/fallback/badge parts

Parts: `avatar_image/1` (`src`, `alt`, `class`, `rest`), `avatar_fallback/1`,
`avatar_badge/1`, `avatar_group/1`, `avatar_group_count/1` — each takes
`class`, `rest` and a `:inner_block` slot.

### card

`UrUi.Components.card/1` — a bounded content surface (shadcn `Card`). Use for
grouping related content and actions, not for every block of page copy.

Compose `card_header/1`, `card_title/1`, `card_description/1`,
`card_action/1`, `card_content/1` and `card_footer/1` inside the root. Put the
action inside the header to align it at the trailing edge. Every part accepts
`class` (appended), `rest` globals and an optional `:inner_block` slot; the
root adds `data-slot="card"` and each part exposes its corresponding slot.

```heex
<.card>
  <.card_header>
    <.card_title>Workspace</.card_title>
    <.card_description>Manage workspace members.</.card_description>
    <.card_action><.button size={:sm}>Edit</.button></.card_action>
  </.card_header>
  <.card_content>Three active members.</.card_content>
  <.card_footer><.button>Save</.button></.card_footer>
</.card>
```

There are no card variants or sizes in shadcn; size through `class` or the
surrounding layout. All seven functions render safely with no optional attrs.

### alert

`UrUi.Components.alert/1` — an assertive status message (shadcn `Alert`), with
`role="alert"` by default. Attrs: `variant` (`:default`, `:destructive`;
default `:default`), `class`, `rest`. Its optional `:inner_block` may contain
an icon marked `data-slot="alert-icon"` and the composable title/description.

Use `alert_title/1` and `alert_description/1` for the two content slots. Both
accept `class`, `rest` and optional `:inner_block`. Add `aria-live="polite"`
through `rest` when the message is not urgent.

```heex
<.alert variant={:destructive}>
  <span data-slot="alert-icon" aria-hidden="true">!</span>
  <.alert_title>Delete failed</.alert_title>
  <.alert_description>Check your permissions and try again.</.alert_description>
</.alert>
```

The destructive variant uses the UR red border/text token. Icons are optional;
there are no sizes in shadcn.


