# ur_ui usage

shadcn/ui `new-york-v4` components ported to Phoenix function components,
using shadcn's default neutral theme in light and dark modes.

## Installation

Add to your `mix.exs`:

```elixir
{:ur_ui, github: "UR-Wife/ur_ui"}
```

## Styling

Import the theme and tell Tailwind v4 to scan this dependency by adding these
lines to the consuming Phoenix application's `assets/css/app.css`:

```css
@import "../../deps/ur_ui/assets/ur_ui.css";
@source "../../deps/ur_ui";
```

The stylesheet defines shadcn's neutral tokens in `:root` and `.dark`, with
Tailwind v4 `@theme` mappings. Apply the `dark` class to an ancestor for dark
mode. Override shadcn tokens rather than hardcoding one-off colors.

## LiveView hooks

Register ur_ui's hooks once in your `assets/js/app.js`:

```javascript
// assets/js/app.js
import {UrUiHooks} from "ur_ui"

const liveSocket = new LiveSocket("/live", Socket, {
  hooks: {...UrUiHooks /* , ...your own hooks */},
  // ...
})
```

`"ur_ui"` resolves to `deps/ur_ui/package.json` through the `NODE_PATH`
(`../deps`) that the default Phoenix esbuild config already sets, the same way
`"phoenix_live_view"` does. The hooks are a plain ES module bundled into your
`app.js`, so there is no inline script and they work under a strict
`Content-Security-Policy`, on Phoenix 1.7 and 1.8.

## Conventions

- Components are plain function components in `UrUi.Components`.
- Variants and sizes are atoms (`variant: :destructive`, `size: :sm`).
- `class` is always accepted to extend, never replace, base classes.
- Missing optional attrs never crash; every attr has a default.
- Focus styling follows shadcn's `:focus-visible` utility classes.

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

- Compose: put `avatar_image/1` before `avatar_fallback/1` inside the root.
  As in Radix, the fallback (initials) shows while the image loads, when it
  fails, or when there is no image; once the image loads, only the image
  shows.
- `avatar_badge/1` for status markers, `avatar_group/1` +
  `avatar_group_count/1` for stacked teams.

Attr   | Type | Default    | Notes
-------|------|------------|------
`size` | atom | `:default` | `:default`, `:sm`, `:lg`
`class`| string | `nil`    | appended to base classes
`rest` | global | —        | `id`, `aria-*`, `phx-*`, `data-*` pass through
slot `:inner_block` | slot | optional | image/fallback/badge parts

Parts: `avatar_image/1` (`id` required, `src`, `alt`, `class`, `rest`),
`avatar_fallback/1`, `avatar_badge/1`, `avatar_group/1`, `avatar_group_count/1`
— each takes `class`, `rest` and a `:inner_block` slot.

The loading/error states use the colocated `.AvatarImage` hook (no inline
script, so it works under a strict CSP). It needs the same one-time
`phoenix-colocated/ur_ui` hooks import as tabs (see **tabs**). Hooks need a
DOM id that stays the same across renders, so `avatar_image/1` requires `id`.
Without the hooks import, the image still shows and the fallback stays
hidden behind it; only the loading/error fallback is missing.

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

The destructive variant uses shadcn's destructive color utilities. Icons are
optional; there are no sizes in shadcn.

### table

`UrUi.Components.table/1` — a semantic table inside a horizontal overflow
container (shadcn `Table`). Attrs: `class`, `rest` and optional `:inner_block`.
The root's globals are applied to `<table>`, not the container.

Compose `table_header/1`, `table_body/1`, `table_footer/1`, `table_row/1`,
`table_head/1`, `table_cell/1` and `table_caption/1`. Every part accepts
`class`, `rest` and optional `:inner_block`; `table_head` also accepts `scope`
(default `"col"`). Mark a selected row with `data-state="selected"` through
`rest`. Use a caption or `aria-label` to name the table.

```heex
<.table>
  <.table_caption>Workspace members</.table_caption>
  <.table_header>
    <.table_row><.table_head>Name</.table_head><.table_head>Role</.table_head></.table_row>
  </.table_header>
  <.table_body>
    <.table_row><.table_cell>Ada</.table_cell><.table_cell>Owner</.table_cell></.table_row>
  </.table_body>
</.table>
```

Shadcn defines no table variants or sizes; layout and alignment belong to the
caller through `class` and global attrs.

### input

`UrUi.Components.input/1` — a native input (shadcn `Input`) with optional
Phoenix form integration. Attrs: `field` (`Phoenix.HTML.FormField`), `id`,
`name`, `value`, `type` (default `"text"`), `errors`, `class` and `rest`.
Explicit `id`/`name`/`value` override the field. File inputs never receive a
`value` attribute.

Pass `field={@form[:email]}` to derive the input id, name, value and errors.
Changeset `{message, options}` errors are interpolated and rendered below the
input; the error container is linked with `aria-describedby`, and invalid
inputs receive `aria-invalid="true"`. Explicit `errors` accept the same tuples
or plain strings.

```heex
<.form for={@form}>
  <.label for={@form[:email].id}>Email</.label>
  <.input field={@form[:email]} type="email" autocomplete="email" />
</.form>
```

The `class` attr extends the input itself; native globals such as `placeholder`,
`required`, `disabled`, `autocomplete` and `accept` pass through `rest`. There
are no shadcn variants or sizes; use native `type` values instead.



### tabs

`UrUi.Components.tabs/1` — accessible tabs (shadcn `Tabs`): a `tablist` of
`<button role="tab">` triggers and one `role="tabpanel"` per content slot,
with the same DOM, ARIA and classes as shadcn/Radix. Attrs: `id` (required),
`default_value`, `class` and `rest`; the `:trigger` and `:content` slots pair
by `value`. Clicking a tab switches client-side through `Phoenix.LiveView.JS`
commands — no server round-trip.

```heex
<.tabs id="account-tabs" default_value="general">
  <:trigger value="general">General</:trigger>
  <:trigger value="security">Security</:trigger>
  <:content value="general">Manage your profile and contact details.</:content>
  <:content value="security">Password and two-factor authentication.</:content>
</.tabs>
```

Each trigger carries `aria-selected`, `aria-controls`, `data-state` and a
roving `tabindex` (only the selected tab is in the Tab order); panels carry
`aria-labelledby`, `tabindex="0"` and `hidden` while inactive. A trigger
whose slot carries `disabled` renders `disabled` and `data-disabled` and is
never selected. `class` extends the root and globals pass through it.

**Keyboard.** Arrow Left/Right move focus and selection to the
previous/next enabled tab (wrapping, skipping disabled tabs); Home and End
jump to the first/last enabled tab, as in Radix. This uses the `UrUiTabs`
hook (see **LiveView hooks** above). Without it, clicking still works; only
arrow-key navigation is missing.

### accordion

`UrUi.Components.accordion/1` — accessible accordion (shadcn `Accordion`)
with matching `:trigger` and `:content` slots. Attrs: `id` (required),
`type` (`:single` default keeps at most one item open — opening an item
closes the others; `:multiple` toggles every item independently),
`default_value` (a value or a list of values that start open), `class` and
`rest`. Toggling runs client-side through `Phoenix.LiveView.JS` commands —
no server round-trip.

```heex
<.accordion id="faq" type="single" default_value="billing">
  <:trigger value="billing">Billing</:trigger>
  <:trigger value="team">Team</:trigger>
  <:content value="billing">Invoices are issued monthly.</:content>
  <:content value="team">Invite teammates from settings.</:content>
</.accordion>
```

Enter and Space toggle an item through the native button. ARIA as in
shadcn: each trigger is a `type="button"` button inside an `h3` heading
with `aria-expanded` and `aria-controls`, and each panel is a
`role="region"` labelled by its trigger with `data-state` and `hidden`.
Items pair by `value`; a trigger without a matching `:content` renders an
empty region. A trigger slot carrying `disabled` renders a disabled button
with no click command.
