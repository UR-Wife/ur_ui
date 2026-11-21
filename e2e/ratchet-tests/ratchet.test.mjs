import assert from 'node:assert/strict'
import { spawnSync } from 'node:child_process'
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { fileURLToPath } from 'node:url'
import test from 'node:test'

const e2eRoot = fileURLToPath(new URL('..', import.meta.url))
const playwrightCli = fileURLToPath(import.meta.resolve('@playwright/test/cli'))
const ratchetModule = fileURLToPath(new URL('../tests/ratchet.ts', import.meta.url))

function collectSpecs(suites, specs = []) {
  for (const suite of suites) {
    specs.push(...(suite.specs ?? []))
    collectSpecs(suite.suites ?? [], specs)
  }
  return specs
}

function makeFixture(t, bodies) {
  const directory = mkdtempSync(join(tmpdir(), 'ur-ui-ratchet-'))
  t.after(() => rmSync(directory, { recursive: true, force: true }))
  const knownFailures = join(directory, 'known-failures.json')
  const report = join(directory, 'results.json')
  const config = join(directory, 'playwright.config.mjs')
  writeFileSync(knownFailures, '[]\n')
  writeFileSync(join(directory, 'package.json'), JSON.stringify({ type: 'module' }))
  writeFileSync(join(directory, 'tsconfig.json'), JSON.stringify({
    compilerOptions: { module: 'ESNext', moduleResolution: 'bundler', target: 'ES2022' },
  }))
  writeFileSync(join(directory, 'fixture.spec.ts'), [
    `import { test } from ${JSON.stringify(ratchetModule)}`,
    ...Object.entries(bodies).map(([title, body]) => `test(${JSON.stringify(title)}, () => { ${body} })`),
    '',
  ].join('\n'))
  writeFileSync(config, `export default {
    testDir: ${JSON.stringify(directory)},
    testMatch: '**/*.spec.ts',
    reporter: [['json', { outputFile: ${JSON.stringify(report)} }]],
    workers: 1,
  }\n`)

  const run = (args = []) => spawnSync(process.execPath, [playwrightCli, 'test', '--config', config, ...args], {
    cwd: e2eRoot,
    encoding: 'utf8',
    env: { ...process.env, PLAYWRIGHT_KNOWN_FAILURES: knownFailures },
  })
  const listed = run(['--list', '--reporter=json'])
  assert.equal(listed.status, 0, listed.stdout + listed.stderr)
  const ids = new Map(collectSpecs(JSON.parse(listed.stdout).suites).map((spec) => [spec.title, spec.id]))
  return { ids, knownFailures, report, run }
}

function failureOutput(result) {
  return `${result.stdout ?? ''}${result.stderr ?? ''}`
}

test('a listed failure is expected and the suite exits zero', (t) => {
  const fixture = makeFixture(t, {
    'known failure': "throw new Error('original failure')",
    'ordinary pass': '',
  })
  writeFileSync(fixture.knownFailures, JSON.stringify([fixture.ids.get('known failure')]))
  const result = fixture.run()
  assert.equal(result.status, 0, failureOutput(result))

  const report = JSON.parse(readFileSync(fixture.report, 'utf8'))
  const specs = new Map(collectSpecs(report.suites).map((spec) => [spec.title, spec]))
  assert.equal(specs.get('known failure').ok, true)
  assert.equal(specs.get('known failure').tests[0].expectedStatus, 'failed')
  assert.equal(specs.get('known failure').tests[0].results[0].status, 'failed')
  assert.equal(specs.get('ordinary pass').ok, true)
  assert.equal(report.stats.unexpected, 0)
})

test('a listed test that passes fails with a removal instruction', (t) => {
  const fixture = makeFixture(t, { 'newly fixed': '' })
  writeFileSync(fixture.knownFailures, JSON.stringify([fixture.ids.get('newly fixed')]))
  const result = fixture.run()
  assert.equal(result.status, 1, failureOutput(result))

  const report = JSON.parse(readFileSync(fixture.report, 'utf8'))
  const spec = collectSpecs(report.suites).find((candidate) => candidate.title === 'newly fixed')
  assert.equal(spec.ok, false)
  const messages = spec.tests[0].results[0].errors.map((error) => error.message).join('\n')
  assert.match(messages, /remove from known-failures\.json/)
  assert.match(failureOutput(result), /remove from known-failures\.json/)
})

test('an unlisted failure remains a failure', (t) => {
  const fixture = makeFixture(t, { 'new regression': "throw new Error('new regression marker')" })
  const result = fixture.run()
  assert.equal(result.status, 1, failureOutput(result))

  const report = JSON.parse(readFileSync(fixture.report, 'utf8'))
  const spec = collectSpecs(report.suites).find((candidate) => candidate.title === 'new regression')
  assert.equal(spec.ok, false)
  assert.equal(spec.tests[0].expectedStatus, 'passed')
  const messages = spec.tests[0].results[0].errors.map((error) => error.message).join('\n')
  assert.match(messages, /new regression marker/)
  assert.doesNotMatch(messages, /remove from known-failures\.json/)
  assert.equal(report.stats.unexpected, 1)
})

test('a listed timeout is expected and the suite exits zero', (t) => {
  const fixture = makeFixture(t, {
    'known timeout': 'test.setTimeout(100); return new Promise(() => {})',
  })
  writeFileSync(fixture.knownFailures, JSON.stringify([fixture.ids.get('known timeout')]))
  const result = fixture.run()
  assert.equal(result.status, 0, failureOutput(result))

  const report = JSON.parse(readFileSync(fixture.report, 'utf8'))
  const spec = collectSpecs(report.suites).find((candidate) => candidate.title === 'known timeout')
  assert.equal(spec.ok, true)
  assert.equal(spec.tests[0].expectedStatus, 'failed')
  assert.equal(report.stats.unexpected, 0)
})
