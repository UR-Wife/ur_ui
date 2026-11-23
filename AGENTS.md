# AGENTS.md — ur_ui repo contract

Authoritative guide for porting shadcn/ui `new-york-v4` components to Phoenix
function components in this repository. Everything here is a hard rule unless a
maintainer says otherwise.

## File naming conventions

- `lib/ur_ui/components.ex` — all function components live in this one module
  (`UrUi.Components`). Names are `snake_case` (`toggle_group/1`,
  `aspect_ratio/1`).
- `test/ur_ui/*_test.exs` — one `snake_case` file per component, named
  `<component>_test.exs` (`switch_test.exs`, `toggle_group_test.exs`).
- `storybook/ur_ui/*.story.exs` — one `kebab-case` file per component
  (`switch.story.exs`, `toggle-group.story.exs`), listed in
  `storybook/ur_ui/_ur_ui.index.exs`.
- `assets/js/ur_ui_hooks.js` — the single JS module exporting `UrUiHooks`;
  hook keys are `CamelCase` (`UrUiToggleGroup`, `UrUiInputOtp`).
- `e2e/` — everything `kebab-case`, both on disk and in the component-name
  lists inside `e2e/scripts/report.mjs` and `e2e/shared/variations.ts`.

## Files required when porting a component `<NAME>`

Port every component with the full set below; missing any one breaks the test
suite or the conformance report.

Elixir / library surface:

- `lib/ur_ui/components.ex` — the `NAME/1` (and any `NAME_part/1`) function(s).
- `assets/js/ur_ui_hooks.js` — a `UrUi<CamelName>` hook **only if the component
  is interactive** (keyboard/roving focus, dynamic transform, OTP entry). Add it
  to the exported `UrUiHooks` map.
- `test/ur_ui/<name>_test.exs` — ExUnit test.
- `USAGE.md` — a `### <name>` section under Components (and update the batch
  sentence at the top of that section). Mirror wording in `README.md` where the
  component set or counts are stated (e.g. the "N components / M variations"
  sentence and the interactive-component list).
- `storybook/ur_ui/<name>.story.exs` + a `def entry("<name>")` line in
  `storybook/ur_ui/_ur_ui.index.exs`.

Reference + differential e2e harness:

- `e2e/reference/src/components/ui/<name>.tsx` — the exact shadcn `new-york-v4`
  source (fetch from the registry; `Slider` imports from `radix-ui`,
  `InputOTP` imports from `input-otp`).
- `e2e/reference/src/App.tsx` — import the reference component(s), add a
  `<Name>Demo` function and a `case '<name>':` in `Demo`.
- `e2e/shared/variations.ts` — add `<name>` to `components` and define its
  `variations`.
- `e2e/tests/conformance.spec.ts` — update the "manifest covers only N
  components" count and the `variations` count.
- `e2e/tests/interactions.spec.ts` — add a `<Name>` check function and register
  the component in the interactive loop **if interactive**, with `check*` logic
  mirrored for both `reference` and `storybook`.
- `e2e/scripts/report.mjs` — add `<name>` to `componentNames`.

Any new reference npm dependency (e.g. `input-otp`) goes into
`e2e/reference/package.json` and `e2e/reference/package-lock.json`.

## Verification gates (must pass before opening a PR)

Run from the repo root:

1. `mix compile --warnings-as-errors`
2. `mix test`
3. `node --check assets/js/ur_ui_hooks.js`
4. `node --check e2e/scripts/report.mjs`

And for a component port, the differential e2e (from `e2e/`):

5. `npm ci && npm ci --prefix reference`
6. `npx playwright install --with-deps chromium` (once)
7. `npm run build:reference && npm run build:storybook && npx tsc --noEmit`
8. `npx playwright test` — conformance **and** interaction (if interactive)
   cases for the ported component must pass; `npm run report` renders the summary.

A visual diff over the 2% `maxDiffPixelRatio` limit is a failure. `axe-core`
runs on both sides; a reference-side axe violation is a known-failure candidate,
not a ur_ui fix.

## Git discipline

1. Branch off `main` (pull latest `origin/main` first). Name it
   `feat/<name>` for ports, `chore/...` / `fix/...` otherwise.
2. Stage explicit paths only — never `git add .` and never stage untracked junk
   (`erl_crash.dump`, `_build/`, `e2e/` results, `.overnight/`).
3. Commit with a one-line message matching repo style
   (`feat(switch): port shadcn Switch as a function component (#23)`).
4. Push the branch to `origin` and open a PR on `UR-Wife/ur_ui` with
   `gh pr create`.
5. Keep each PR to one component (or one chore/fix).

## Stop rule

On any conformance diff or test failure, make **at most 3 fix attempts**. If it
still fails, stop looping and document in the PR description: the exact root
cause, the failing file and line, and the measured diff % (or the failing
assertion). Do not keep guessing.
