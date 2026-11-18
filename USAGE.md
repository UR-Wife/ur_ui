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