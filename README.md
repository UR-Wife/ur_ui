# ur_ui

Phoenix function components faithfully ported from shadcn/ui `new-york-v4`,
using shadcn's default neutral theme in light and dark modes.
See [USAGE.md](USAGE.md) for component APIs and examples.

## Installation

Add the dependency to your Phoenix application's `mix.exs`:

```elixir
{:ur_ui, github: "UR-Wife/ur_ui"}
```

## Tailwind v4 setup

Tailwind does not scan dependency files by default. In the consuming Phoenix
application's `assets/css/app.css`, import the theme and add this exact source
line so Tailwind sees the component classes:

```css
@import "../../deps/ur_ui/assets/ur_ui.css";
@source "../../deps/ur_ui";
```

The stylesheet defines shadcn's neutral tokens in `:root` and `.dark`, plus
the Tailwind v4 `@theme` mappings used by the components. Apply the `dark`
class to an ancestor to use dark mode.

## Credits and license

The theme values and component class strings come from
[shadcn/ui](https://github.com/shadcn-ui/ui), `new-york-v4`. shadcn/ui is
copyright (c) 2023 shadcn and distributed under the MIT license. Its complete
copyright and permission notice is included in
[LICENSES/shadcn-ui-LICENSE.md](LICENSES/shadcn-ui-LICENSE.md).

ur_ui retains its own MIT license in [LICENSE](LICENSE).
