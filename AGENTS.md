# ur_ui — OpenCode lane brief

`ur_ui` ships shadcn/ui new-york-v4 components as Phoenix function components.
CI evidence comes from RWX (`.rwx/tasks.yml`), not GitHub Actions; keep the two
in parity when you add or move tests.

## Workflow

- Branch off `main`; naming convention `feat/<topic>`, `fix/<topic>`.
- Never edit `e2e/known-failures.json` or `.github/` in a lane PR — those are
  curated by a human.
- Never autoplay, never hardcode colors (the design system lives in `assets/`,
  `priv/static/`, and `storybook/`; components map classes, they do not invent
  them).

## Running tests inside the RWX sandbox

`rwx` is already authenticated on this host; there is no token file to load.

```bash
# run a single ExUnit file inside the sandbox; results sync back to this tree
rwx sandbox exec -- mix test test/ur_ui/checkbox_test.exs

# regenerate the mix.lock with no local Elixir install
rwx sandbox exec -- mix deps.get

# full CI parity run (elixir + e2e), blocking
rwx run .rwx/tasks.yml --wait

# lint the RWX definitions before committing
rwx lint .rwx/tasks.yml .rwx/sandbox.yml
```

## Test scaffolding

- `test-elixir` writes a JUnit report to `tmp/junit/ur-ui-test-junit-report.xml`
  via `junit_formatter` (config in `config/test.exs`); RWX reads it as
  `outputs.test-results`. Keep `--formatter JUnitFormatter` in the task.
- `test-e2e` drives Playwright against the reference React app and the
  Storybook dev server (both started by `e2e/playwright.config.ts` `webServer`).

## Machinery fence

`.rwx/machinery-paths.txt` fences `.rwx/**`, `factory.yml`, and `AGENTS.md`;
changes there must never be self-approved. Human approvers live in
`.rwx/human-approvers.txt`.
