import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { expect, test as base } from '@playwright/test'

const knownFailuresPath = process.env.PLAYWRIGHT_KNOWN_FAILURES
  ?? fileURLToPath(new URL('../known-failures.json', import.meta.url))
// Each entry is a test ID, or { "id": ..., "note": ... } when the failure needs
// an explanation (for example a bug in the shadcn reference itself).
type KnownFailure = string | { id: string; note?: string }
const knownFailures = new Set<string>(
  (JSON.parse(readFileSync(knownFailuresPath, 'utf8')) as KnownFailure[])
    .map((entry) => typeof entry === 'string' ? entry : entry.id),
)

export const test = base.extend<{ knownFailureRatchet: void }>({
  knownFailureRatchet: [async ({}, use, testInfo) => {
    const isKnownFailure = knownFailures.has(testInfo.testId)
    testInfo.fail(isKnownFailure)
    await use()
    if (isKnownFailure && testInfo.status === 'timedOut') {
      testInfo.status = 'failed'
    }
    if (isKnownFailure && testInfo.status === 'passed') {
      testInfo.expectedStatus = 'passed'
      throw new Error('Test now passes: remove from known-failures.json')
    }
  }, { auto: true }],
})

export { expect }
