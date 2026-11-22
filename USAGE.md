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
textarea, checkbox, collapsible, kbd, breadcrumb, progress, radio-group, spinner, switch, toggle, tabs, accordion).

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

### toggle

`UrUi.Components.toggle/1` — a pressable button with an on/off state (shadcn
`Toggle`). It renders `aria-pressed` and `data-state="on|off"`; toggling runs
client-side through `Phoenix.LiveView.JS` commands, so no server round-trip.

- Use for toolbar-style on/off controls (bold, italic, …).
- `variant: :outline` draws a border; `size` controls the sizing.

Attr       | Type   | Default    | Notes
-----------|--------|------------|------
`variant`  | atom   | `:default` | `:default`, `:outline`
`size`     | atom   | `:default` | `:default`, `:sm`, `:lg`
`pressed`  | boolean| `false`    | initial pressed state
`disabled` | boolean| `false`    | disables the toggle
`class`    | string | `nil`      | appended to base classes
`rest`     | global | —          | `id`, `aria-*`, `phx-*`, `data-*` pass through
slot `:inner_block` | slot | required | toggle content

### badge

`UrUi.Components.badge/1` — small status descriptor (shadcn `Badge`): a
fully rounded pill (`rounded-full`) with shadcn's exact classes; `:outline`
draws a `border-border` outline and the other variants a transparent border.

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

### kbd

`UrUi.Components.kbd/1` — a keyboard key or key combination (shadcn `Kbd`):
a `<kbd>` element with shadcn's exact classes. `kbd_group/1` wraps several
keys into a combination.

- Use for keyboard shortcuts in docs, tooltips and menus.
- Keep content to the key label (e.g. `K`, `⌘`, `Ctrl`).

Attr       | Type   | Default | Notes
-----------|--------|---------|------
`class`    | string | `nil`   | appended to base classes
`rest`     | global | —       | `id`, `aria-*`, `phx-*`, `data-*` pass through
slot `:inner_block` | slot | required | key label

`kbd_group/1` takes the same `class`, `rest` and `:inner_block` slot and
renders a `<kbd data-slot="kbd-group">` that lays out its keys with a small
gap.

### breadcrumb

`UrUi.Components.breadcrumb/1` — a page-path breadcrumb (shadcn
`Breadcrumb`). Compose the parts inside the root:

```heex
<.breadcrumb>
  <.breadcrumb_list>
    <.breadcrumb_item>
      <.breadcrumb_link href="/">Home</.breadcrumb_link>
    </.breadcrumb_item>
    <.breadcrumb_separator />
    <.breadcrumb_item>
      <.breadcrumb_page>Current</.breadcrumb_page>
    </.breadcrumb_item>
  </.breadcrumb_list>
</.breadcrumb>
```

Parts: `breadcrumb_list/1` (the `<ol>`, ARIA `aria-label="breadcrumb"` lives on
the `<nav>` root), `breadcrumb_item/1` (one `<li>` per crumb),
`breadcrumb_link/1` (`href` for a crumb that navigates), `breadcrumb_page/1`
(the current page: `role="link"`, `aria-disabled` and `aria-current="page"`),
`breadcrumb_separator/1` (a decorative chevron, `role="presentation"`) and
`breadcrumb_ellipsis/1` (the collapsed "More" placeholder). Each accepts
`class`, `rest` and an optional `:inner_block` slot.

### spinner

`UrUi.Components.spinner/1` — an accessible loading indicator (shadcn
`Spinner`): a lucide loader icon sized `size-4` and animated with
`animate-spin`, marked `role="status"` and `aria-label="Loading"`. Size it up
or down through `class` (`class: "size-8"`).

Attr    | Type   | Default | Notes
--------|--------|---------|------
`class` | string | `nil`   | appended to base classes (sizing lives here)
`rest`  | global | —       | `id`, `aria-*`, `data-*` pass through

### progress

`UrUi.Components.progress/1` — a determinate progress bar (shadcn `Progress`).
Attrs: `value` (default `0`), `max` (default `100`), `class` and `rest`. It
renders `role="progressbar"` with the `aria-valuemin`/`aria-valuemax`/
`aria-valuenow`/`aria-valuetext` attributes, plus `data-state` (`loading` or
`complete`).

```heex
<.progress value={60} />
```

The fill position is applied by the `UrUiProgress` hook (see **LiveView
hooks** above): it sets the indicator's `translateX` transform through the
CSSOM, so the markup carries no inline style and works under a strict
Content-Security-Policy. Size it through `class` (e.g. `class: "w-64"`).

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
  `role="separator"` (plus `aria-orientation="vertical"` when vertical).
  Decorative separators render `role="none"`, exactly as Radix does.
- Like shadcn's, it sizes from its container: horizontal is `w-full` and
  vertical is `h-full`, so give a vertical separator a sized row, as in the
  shadcn docs:

```heex
<div class="flex h-5 items-center space-x-4 text-sm">
  <div>Blog</div>
  <.separator orientation={:vertical} />
  <div>Docs</div>
</div>
```

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

The loading/error states use the `UrUiAvatarImage` hook (see **LiveView
hooks** above). Hooks need a DOM id that stays the same across renders, so
`avatar_image/1` requires `id`. Without the hooks, the image still shows and
the fallback stays hidden behind it; only the loading/error fallback is
missing.

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

Always give an input an accessible name. As in the shadcn docs, pair it with
a `label` whose `for` matches the input id:

```heex
<div class="grid w-full max-w-sm items-center gap-3">
  <.label for="picture">Picture</.label>
  <.input id="picture" name="picture" type="file" />
</div>
```



### textarea

`UrUi.Components.textarea/1` — a native textarea (shadcn `Textarea`) with
optional Phoenix form integration. Attrs: `field` (`Phoenix.HTML.FormField`),
`id`, `name`, `value`, `errors`, `class` and `rest`. Explicit
`id`/`name`/`value` override the field. The value renders as the textarea's
text content, not a `value` attribute.

Pass `field={@form[:bio]}` to derive the textarea id, name, value and errors.
Changeset `{message, options}` errors are interpolated and rendered below the
textarea; the error container is linked with `aria-describedby`, and invalid
textareas receive `aria-invalid="true"`. Explicit `errors` accept the same
tuples or plain strings.

```heex
<.form for={@form}>
  <.label for={@form[:bio].id}>Bio</.label>
  <.textarea field={@form[:bio]} placeholder="Tell us about yourself" />
</.form>
```

The `class` attr extends the textarea itself; native globals such as
`placeholder`, `rows`, `required` and `disabled` pass through `rest`. There
are no shadcn variants or sizes.

### checkbox

`UrUi.Components.checkbox/1` — a button-based checkbox (shadcn `Checkbox`)
matching Radix's DOM and ARIA: a `<button type="button" role="checkbox">`
with `aria-checked`, `data-state` and a check indicator. Attrs: `id`
(required), `name`, `value` (default `"on"`), `checked` (default `false`),
`disabled`, `required`, `class` and `rest`. Toggling runs client-side through
`Phoenix.LiveView.JS` commands — no server round-trip.

```heex
<div class="flex items-center gap-2">
  <.checkbox id="terms" name="terms" />
  <label for="terms" class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
    Accept terms and conditions
  </label>
</div>
```

When `name` is given it also renders a hidden `<input type="checkbox">` (as
Radix does) so the value submits with a form; the hidden input's `checked`
state stays in sync with the button. `checked` sets the initial state; the
check indicator is hidden while unchecked. `class` extends the button and
globals pass through it. As in the shadcn docs, pair it with a `label` whose
`for` matches the checkbox id.

**Keyboard.** Space toggles the checkbox; Enter does not, as in Radix. This
uses the `UrUiCheckbox` hook (see **LiveView hooks** above). Without it,
clicking and Space still work; only Enter would also toggle.

The hidden input's `checked` state is toggled through its `checked` attribute,
so a native `form.reset()` restores the toggled state rather than the initial
`checked` value. Use a LiveView re-render (the usual Phoenix flow) to reset a
checkbox to its initial state.

### switch

`UrUi.Components.switch/1` — an on/off switch (shadcn `Switch`): a
`<button role="switch">` with `aria-checked`, `data-state` and a sliding
thumb. Attrs: `id` (required), `name`, `value` (default `"on"`), `size`
(`:default`, `:sm`), `checked` (default `false`), `disabled`, `required`,
`class` and `rest`. Toggling runs client-side through `Phoenix.LiveView.JS`
commands — no server round-trip.

```heex
<div class="flex items-center justify-between gap-4">
  <div class="grid gap-1.5 leading-none">
    <label for="strict-mode" class="text-sm font-medium">Strict mode</label>
    <p class="text-sm text-muted-foreground">Enforce additional checks</p>
  </div>
  <.switch id="strict-mode" name="strict_mode" />
</div>
```

When `name` is given it also renders a hidden `<input type="checkbox">` whose
`checked` state stays in sync and which dispatches `change` after toggling, so
the value submits with a form. `class` extends the button; globals pass through
`rest`. Unlike the checkbox, Space and Enter both toggle the switch.

### radio-group

`UrUi.Components.radio_group/1` — a `role="radiogroup"` of button-based radio
items (shadcn `RadioGroup`). Attrs: `id` (required), `name`, `default_value`,
`disabled`, `class` and `rest`; each `:item` slot carries a `value` (required)
and optional `disabled`, and its content is the item's label. Selection runs
client-side through `Phoenix.LiveView.JS` commands.

```heex
<.radio_group id="size" name="size" default_value="comfortable">
  <:item value="default">Default</:item>
  <:item value="comfortable">Comfortable</:item>
</.radio_group>
```

Each item renders `aria-checked`, `data-state` and a roving `tabindex` (only
the checked item is in the Tab order); the checked item shows a filled dot.
When `name` is given a hidden `<input type="radio">` is rendered per item, with
`change` dispatched on the selected input.

**Keyboard.** Arrow Up/Left/Down/Right move focus and selection to the
previous/next enabled item (wrapping); Home and End jump to the first/last, as
in Radix. This uses the `UrUiRadioGroup` hook (see **LiveView hooks** above).
Without it, clicking still works; only arrow-key navigation is missing.

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

### collapsible

`UrUi.Components.collapsible/1` — a trigger button that toggles a single
collapsible region (shadcn `Collapsible`). Attrs: `id` (required),
`default_open` (default `false`), `class` and `rest`; the `:trigger` and
`:content` slots pair up, and the trigger slot may carry `disabled`. Toggling
runs client-side through `Phoenix.LiveView.JS` commands — no round-trip.

```heex
<.collapsible id="faq" default_open>
  <:trigger>Can I use this in my project?</:trigger>
  <:content>Yes. Free to use for personal and commercial projects.</:content>
</.collapsible>
```

The trigger carries `aria-expanded` and `aria-controls`; the content is
`hidden` while closed and carries a matching `data-state` (`open`/`closed`).
The root exposes `data-slot="collapsible"` and `data-state` as in Radix. Add
shadcn's animation classes through `class` if you want the animated collapse.
