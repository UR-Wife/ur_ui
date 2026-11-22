import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { dirname, isAbsolute, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const resultsDir = resolve(root, 'results')
const resultsPath = resolve(resultsDir, 'results.json')
const componentNames = [
  'accordion', 'alert', 'avatar', 'badge', 'breadcrumb', 'button', 'card',
  'checkbox', 'input', 'kbd', 'label', 'separator', 'skeleton', 'spinner', 'table', 'tabs', 'toggle', 'textarea',
]
mkdirSync(resultsDir, { recursive: true })

function collectSuites(suite, specs = []) {
  specs.push(...(suite.specs ?? []))
  for (const child of suite.suites ?? []) collectSuites(child, specs)
  return specs
}

function readCaseResult(test) {
  const lastResult = test.results?.at(-1)
  const attachment = lastResult?.attachments?.find((entry) => entry.name === 'ur-ui-result')
  if (!attachment?.path) return {}
  const path = isAbsolute(attachment.path) ? attachment.path : resolve(root, attachment.path)
  return existsSync(path) ? JSON.parse(readFileSync(path, 'utf8')) : {}
}

function fallbackCase(spec, test) {
  const title = spec.title
  const variation = title.match(/^(.*) \[(light|dark)\]$/)?.[1] ?? title
  const theme = title.match(/\[(light|dark)\]$/)?.[1] ?? 'unknown'
  const error = test.results?.at(-1)?.errors?.[0]?.message?.split('\n').slice(0, 4).join('\n')
  return {
    component: variation.split('/')[0],
    variation,
    theme,
    kind: spec.file === 'interactions.spec.ts' ? 'interaction' : 'conformance',
    failures: [{ check: 'infrastructure', message: error ?? 'No structured result was emitted' }],
  }
}

const report = existsSync(resultsPath) ? JSON.parse(readFileSync(resultsPath, 'utf8')) : { suites: [] }
const specs = (report.suites ?? []).flatMap((suite) => collectSuites(suite))
const cases = []
for (const spec of specs) {
  if (spec.file === 'interactions.spec.ts' || spec.title.includes(' [light]') || spec.title.includes(' [dark]')) {
    for (const test of spec.tests ?? []) {
      if (test.projectName && test.projectName !== 'chromium') continue
      const fallback = fallbackCase(spec, test)
      const structured = readCaseResult(test)
      const value = { ...fallback, ...structured }
      value.passed = Boolean(spec.ok) && (value.failures?.length ?? 0) === 0
      cases.push(value)
    }
  }
}

const components = componentNames.map((component) => {
  const entries = cases.filter((value) => value.component === component)
  const conformance = entries.filter((value) => value.kind === 'conformance')
  const interaction = entries.filter((value) => value.kind === 'interaction')
  const passed = entries.filter((value) => value.passed).length
  return {
    component,
    status: entries.length === 0 ? 'NOT RUN' : passed === entries.length ? 'PASS' : 'FAIL',
    passed,
    total: entries.length,
    conformancePassed: conformance.filter((value) => value.passed).length,
    conformanceTotal: conformance.length,
    interactionPassed: interaction.filter((value) => value.passed).length,
    interactionTotal: interaction.length,
  }
})
const failedCases = cases.filter((value) => !value.passed)
function describeFailure(failure) {
  const violations = (Array.isArray(failure.details) ? failure.details : []).flatMap((violation) =>
    (violation.nodes ?? []).map((node) => `${violation.id} at ${node.target.join(', ')}: ${node.failureSummary}`),
  )
  return violations?.length ? `${failure.message} — ${violations.join('; ')}` : failure.message
}
const lines = [
  '# ur_ui vs shadcn conformance',
  '',
  'Reference: shadcn CLI `new-york-v4`, neutral default theme. Screenshot limit: `maxDiffPixelRatio = 0.02`.',
  '',
  `Cases: ${cases.length}; passed: ${cases.length - failedCases.length}; failed: ${failedCases.length}.`,
  '',
  '| Component | Result | Conformance | Keyboard/ARIA |',
  '| --- | --- | ---: | ---: |',
  ...components.map((entry) => `| ${entry.component} | ${entry.status} | ${entry.conformancePassed}/${entry.conformanceTotal} | ${entry.interactionPassed}/${entry.interactionTotal} |`),
  '',
  '## Failing components and diffs',
  '',
]
if (failedCases.length === 0) {
  lines.push(cases.length === 0 ? 'No Playwright results were found; all components are NOT RUN.' : 'None. All executed cases pass.')
} else {
  for (const component of components.filter((entry) => entry.status === 'FAIL')) {
    lines.push(`### ${component.component}`, '')
    for (const value of failedCases.filter((entry) => entry.component === component.component)) {
      const failures = value.failures?.length
        ? value.failures.map((failure) => `${failure.check}: ${describeFailure(failure)}`).join(' | ')
        : 'Playwright reported a failure without structured detail'
      lines.push(`- \`${value.variation}\` (${value.theme}, ${value.kind}) — ${failures}`)
    }
    lines.push('')
  }
}
lines.push(
  'Raw per-case style values, axe nodes, exact screenshot ratios, and failure PNGs are in the Playwright JSON and test-results artifacts.',
  '',
)
writeFileSync(resolve(resultsDir, 'summary.json'), JSON.stringify({ components, cases }, null, 2))
writeFileSync(resolve(resultsDir, 'conformance.md'), lines.join('\n'))
console.log(lines.join('\n'))
