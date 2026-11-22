import { readFileSync, writeFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import AxeBuilder from '@axe-core/playwright'
import { expect, type Locator, type Page, type TestInfo } from '@playwright/test'
import pixelmatch from 'pixelmatch'
import { PNG } from 'pngjs'
import type { Theme, Variation } from '../shared/variations'

export const MAX_DIFF_PIXEL_RATIO = 0.02
export const STYLE_PROPERTIES = [
  'background-color',
  'color',
  'padding',
  'border-radius',
  'font-size',
  'font-weight',
  'border-width',
] as const

export interface CaseFailure {
  check: 'styles' | 'screenshot' | 'axe-reference' | 'axe-storybook' | 'interaction' | 'infrastructure'
  message: string
  details?: unknown
}

export interface CaseResult {
  component: string
  variation: string
  theme: Theme
  kind: 'conformance' | 'interaction'
  failures: CaseFailure[]
  styles?: { reference: Record<string, string>; storybook: Record<string, string> }
  screenshotDiffRatio?: number
  maxDiffPixelRatio: number
}

const storybookCss = fileURLToPath(new URL('../.generated/ur_ui.css', import.meta.url))
const referenceUrl = process.env.REFERENCE_URL ?? 'http://127.0.0.1:4173'
const storybookUrl = process.env.STORYBOOK_URL ?? 'http://127.0.0.1:4000'

export function mainLocator(page: Page, variation: Variation): Locator {
  return page.locator(`[data-slot="${variation.component}"]`).first()
}

export function storybookMainLocator(page: Page, variation: Variation): Locator {
  return page.locator(`#${variation.storyId}[data-slot="${variation.component}"], #${variation.storyId} [data-slot="${variation.component}"]`).first()
}

export function screenshotLocator(page: Page, variation: Variation): Locator {
  const slot = variation.screenshotSlot ?? variation.component
  return page.locator(`[data-slot="${slot}"]`).first()
}

export function storybookScreenshotLocator(page: Page, variation: Variation): Locator {
  const slot = variation.screenshotSlot ?? variation.component
  return page.locator(`#${variation.storyId}[data-slot="${slot}"], [data-slot="${slot}"]:has(#${variation.storyId})`).first()
}

async function settle(page: Page, main: Locator, theme: Theme) {
  await page.evaluate(async (selectedTheme) => {
    const style = document.createElement('style')
    style.textContent = '*, *::before, *::after { transition: none !important; animation: none !important; caret-color: transparent !important; }'
    document.head.append(style)
    document.documentElement.classList.toggle('dark', selectedTheme === 'dark')
    document.documentElement.style.colorScheme = selectedTheme
    document.body.style.backgroundColor = 'var(--background)'
    document.body.style.color = 'var(--foreground)'
    await document.fonts.ready
  }, theme)
  await main.evaluate((element) => {
    const fontFamily = getComputedStyle(document.documentElement).fontFamily
    for (let ancestor = element.parentElement; ancestor; ancestor = ancestor.parentElement) {
      ancestor.style.fontFamily = fontFamily
      ancestor.style.backgroundColor = 'var(--background)'
    }
  })
}

export async function openReference(page: Page, variation: Variation, theme: Theme) {
  await page.emulateMedia({ colorScheme: theme })
  await page.goto(`${referenceUrl}${variation.route}`, { waitUntil: 'networkidle' })
  const main = mainLocator(page, variation)
  await main.waitFor({ state: 'visible' })
  await settle(page, main, theme)
  return main
}

export async function openStorybook(page: Page, variation: Variation, theme: Theme) {
  await page.emulateMedia({ colorScheme: theme })
  await page.route(/\/ur_ui\.css(?:\?.*)?$/, async (route) => {
    await route.fulfill({ contentType: 'text/css', body: readFileSync(storybookCss) })
  })
  await page.addInitScript((selectedTheme) => {
    document.documentElement.classList.toggle('dark', selectedTheme === 'dark')
    document.documentElement.style.colorScheme = selectedTheme
  }, theme)
  await page.goto(`${storybookUrl}${variation.storyPath}`, { waitUntil: 'networkidle' })
  const main = storybookMainLocator(page, variation)
  await main.waitFor({ state: 'visible' })
  await settle(page, main, theme)
  return main
}

export async function matchReferenceParentWidth(reference: Locator, storybook: Locator) {
  const container = reference.locator('xpath=ancestor::*[@data-reference-container][1]')
  const parent = await storybook.evaluate((element) => {
    const parentElement = element.parentElement
    if (!parentElement) throw new Error('Storybook example has no parent container')
    const style = getComputedStyle(parentElement)
    return {
      width: parentElement.getBoundingClientRect().width,
      contentWidth: parentElement.clientWidth - parseFloat(style.paddingLeft) - parseFloat(style.paddingRight),
      display: style.display,
      flexDirection: style.flexDirection,
      alignItems: style.alignItems,
      justifyContent: style.justifyContent,
    }
  })
  if (await container.getAttribute('data-match-storybook-width') !== null) {
    await container.evaluate((element, parentWidth) => {
      element.style.width = `${parentWidth}px`
    }, parent.width)
    return
  }
  // Give the reference example the same layout box Storybook gives ur_ui: the
  // cell's content width and its flex alignment. Otherwise w-full examples
  // (alert) fill the cell in Storybook but shrink to their text in the
  // reference, and wide text (card) wraps in the narrow cell only, which makes
  // results depend on the machine's fonts.
  await container.evaluate((element, layout) => {
    element.style.boxSizing = 'content-box'
    element.style.width = `${layout.contentWidth}px`
    element.style.display = layout.display
    element.style.flexDirection = layout.flexDirection
    element.style.alignItems = layout.alignItems
    element.style.justifyContent = layout.justifyContent
  }, parent)
}

export async function alignReferenceOrigin(reference: Locator, storybook: Locator) {
  const [referenceBounds, storybookBounds] = await Promise.all([reference.boundingBox(), storybook.boundingBox()])
  if (!referenceBounds || !storybookBounds) throw new Error('Cannot align hidden component bounds')
  const rawX = storybookBounds.x - referenceBounds.x
  const rawY = storybookBounds.y - referenceBounds.y
  const offset = { x: rawX - Math.round(rawX), y: rawY - Math.round(rawY) }
  await reference.evaluate((element, { x, y }) => {
    document.body.style.position = 'relative'
    document.body.style.left = `${x}px`
    document.body.style.top = `${y}px`
    element.getBoundingClientRect()
  }, offset)
}

export async function checkComputedStyles(
  reference: Locator,
  storybook: Locator,
  result: CaseResult,
) {
  const read = (locator: Locator) => locator.evaluate((element, properties) => {
    const style = getComputedStyle(element)
    return Object.fromEntries(properties.map((property) => [property, style.getPropertyValue(property)]))
  }, [...STYLE_PROPERTIES])
  const [referenceStyles, storybookStyles] = await Promise.all([read(reference), read(storybook)])
  result.styles = { reference: referenceStyles, storybook: storybookStyles }
  const differences = STYLE_PROPERTIES.flatMap((property) => {
    if (referenceStyles[property] === storybookStyles[property]) return []
    return [{
      property,
      reference: referenceStyles[property],
      storybook: storybookStyles[property],
    }]
  })
  if (differences.length) {
    result.failures.push({
      check: 'styles',
      message: differences.map((difference) => `${difference.property}: ${difference.storybook} != ${difference.reference}`).join('; '),
      details: differences,
    })
  }
  expect.soft(storybookStyles, 'computed styles must exactly match shadcn').toEqual(referenceStyles)
}

export async function checkScreenshots(
  reference: Locator,
  storybook: Locator,
  testInfo: TestInfo,
  result: CaseResult,
) {
  const [referenceBuffer, storybookBuffer] = await Promise.all([
    reference.screenshot({ animations: 'disabled' }),
    storybook.screenshot({ animations: 'disabled' }),
  ])
  const expected = PNG.sync.read(referenceBuffer)
  const actual = PNG.sync.read(storybookBuffer)
  const dimensionsMatch = expected.width === actual.width && expected.height === actual.height
  const width = Math.max(expected.width, actual.width)
  const height = Math.max(expected.height, actual.height)
  const fill = result.theme === 'dark' ? 10 : 255
  const makeCanvas = () => {
    const canvas = new PNG({ width, height })
    for (let index = 0; index < canvas.data.length; index += 4) {
      canvas.data[index] = fill
      canvas.data[index + 1] = fill
      canvas.data[index + 2] = fill
      canvas.data[index + 3] = 255
    }
    return canvas
  }
  const expectedCanvas = makeCanvas()
  const actualCanvas = makeCanvas()
  PNG.bitblt(expected, expectedCanvas, 0, 0, expected.width, expected.height, 0, 0)
  PNG.bitblt(actual, actualCanvas, 0, 0, actual.width, actual.height, 0, 0)
  const diff = new PNG({ width, height })
  const differentPixels = pixelmatch(expectedCanvas.data, actualCanvas.data, diff.data, width, height, { threshold: 0.2 })
  const ratio = differentPixels / (width * height)
  result.screenshotDiffRatio = ratio

  if (ratio > MAX_DIFF_PIXEL_RATIO || !dimensionsMatch) {
    const referencePath = testInfo.outputPath('reference.png')
    const storybookPath = testInfo.outputPath('storybook.png')
    const diffPath = testInfo.outputPath('diff.png')
    writeFileSync(referencePath, referenceBuffer)
    writeFileSync(storybookPath, storybookBuffer)
    writeFileSync(diffPath, PNG.sync.write(diff))
    await testInfo.attach('reference', { path: referencePath, contentType: 'image/png' })
    await testInfo.attach('storybook', { path: storybookPath, contentType: 'image/png' })
    await testInfo.attach('diff', { path: diffPath, contentType: 'image/png' })
    const message = `${(ratio * 100).toFixed(3)}% pixels differ (limit 2%); reference ${expected.width}x${expected.height}, ur_ui ${actual.width}x${actual.height}`
    result.failures.push({ check: 'screenshot', message, details: { ratio, dimensionsMatch } })
  }
  expect.soft(ratio, 'screenshot diff ratio').toBeLessThanOrEqual(MAX_DIFF_PIXEL_RATIO)
  expect.soft(dimensionsMatch, 'screenshot dimensions must match').toBe(true)
}

export async function checkAxe(
  page: Page,
  selector: string,
  side: 'reference' | 'storybook',
  result: CaseResult,
) {
  const analysis = await new AxeBuilder({ page }).include(selector).analyze()
  if (analysis.violations.length) {
    const violations = analysis.violations.map((violation) => ({
      id: violation.id,
      impact: violation.impact,
      description: violation.description,
      nodes: violation.nodes.map((node) => ({ target: node.target, failureSummary: node.failureSummary })),
    }))
    result.failures.push({
      check: side === 'reference' ? 'axe-reference' : 'axe-storybook',
      message: violations.map((violation) => `${violation.id} (${violation.nodes.length} nodes)`).join('; '),
      details: violations,
    })
  }
  expect.soft(analysis.violations, `${side} axe violations`).toEqual([])
}

export async function saveCaseResult(testInfo: TestInfo, result: CaseResult) {
  const path = testInfo.outputPath('case-result.json')
  writeFileSync(path, JSON.stringify(result, null, 2))
  await testInfo.attach('ur-ui-result', { path, contentType: 'application/json' })
}
