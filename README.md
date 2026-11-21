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

## shadcn conformance e2e

The differential harness covers all 12 components and 63 Storybook variations
in light and dark modes. It compares seven computed-style properties, applies
a 2% screenshot diff limit, checks accordion/tabs keyboard and ARIA behavior,
and runs axe-core on both implementations. The reference is generated with
the shadcn CLI using `new-york-v4` and the default neutral theme.

All Node tooling is isolated under `e2e/`; the Mix and Hex package dependencies
are unchanged. With Elixir/OTP and Node.js 22 or newer installed, run:

```sh
mix deps.get
cd e2e
npm ci
npm ci --prefix reference
npx playwright install chromium
npm test
```

`npm test` builds the Vite reference and the Storybook-only compiled CSS, then
Playwright starts the reference preview and `mix phx.server`. Existing servers
on ports 4173 and 4000 are reused locally. To start them yourself, use
`npm run preview:reference` from `e2e/` and `mix phx.server` from the repository
root. `REFERENCE_URL` and `STORYBOOK_URL` can override the default URLs.

Generate the per-component Markdown/JSON summary with `npm run report`, and open
the HTML report with `npx playwright show-report`. Raw style diffs, axe nodes,
screenshots, and traces are written under `e2e/results/` and `e2e/test-results/`.
The CI workflow uploads these files as the `playwright-report` artifact.

## Credits and license

The theme values and component class strings come from
[shadcn/ui](https://github.com/shadcn-ui/ui), `new-york-v4`. shadcn/ui is
copyright (c) 2023 shadcn and distributed under the MIT license. Its complete
copyright and permission notice is included in
[LICENSES/shadcn-ui-LICENSE.md](LICENSES/shadcn-ui-LICENSE.md).

ur_ui retains its own MIT license in [LICENSE](LICENSE).
