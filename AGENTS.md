# ur_ui AGENTS.md

Lane brief for the `UR-Wife/ur_ui` OpenCode `/oc` lane.

## /oc prompt contract

The `/oc` lane is driven by the `.github/workflows/opencode.yml` GitHub Action.
It reacts to two signals:

- An `issue_comment` whose body starts with `/oc` and whose author is an
  `OWNER`, `MEMBER`, or `COLLABORATOR` (external users cannot trigger the
  runner).
- A `pull_request_review` whose body contains `<!-- greptile_summary -->`
  (posted by Greptile after a review).

### Issue-to-PR discipline

When asked to act on an issue, the lane must:

1. Read the full issue thread and every comment before writing code.
2. Sweep for duplicate issues/PRs and never duplicate in-flight work.
3. Reproduce the problem (or pin the acceptance criteria) before editing.
4. Fix test-first: write/adjust the failing test, run it to prove the failure,
   then make it pass.
5. Prove it: `mix test` and, when UI is touched, the Playwright suite
   (`MIX_ENV=dev mix deps.get && cd e2e && npx playwright test`).
6. Open a PR that references the issue, with `RWX: CI` expected to trigger.

### Greptile loop

When re-entered by a Greptile summary, the lane:

- Fixes findings in rounds.
- Stops when the review is clean (5/5) or after 5 rounds, whichever first.
- Resolves every finding with evidence (a passing test or a diff), never with a
  bare claim.
- Never reworks code that is already correct just to satisfy a summary line; a
  disagreement is documented as a comment, not silently "fixed".

## Invariants

- Never autoplay widgets; never hardcode colors or theme tokens.
- Components are Phoenix function components ported from shadcn/ui
  `new-york-v4`, neutral theme, light + dark mode.
