import { test } from './ratchet'
import { components, variationKey, variations, type Theme } from '../shared/variations'
import {
  alignReferenceOrigin,
  checkAxe,
  checkComputedStyles,
  checkScreenshots,
  mainLocator,
  openReference,
  openStorybook,
  saveCaseResult,
  screenshotLocator,
  storybookMainLocator,
  storybookScreenshotLocator,
  MAX_DIFF_PIXEL_RATIO,
  type CaseResult,
} from './helpers'

test('manifest covers only the 12 components with unique routes and story IDs', () => {
  test.expect(components).toHaveLength(12)
  test.expect(variations).toHaveLength(63)
  test.expect(new Set(variations.map((variation) => variation.route)).size).toBe(variations.length)
  test.expect(new Set(variations.map((variation) => variation.storyId)).size).toBe(variations.length)
  test.expect(new Set(variations.map((variation) => variation.component))).toEqual(new Set(components))
})

test.describe('shadcn conformance', () => {
  for (const variation of variations) {
    for (const theme of ['light', 'dark'] as Theme[]) {
      const key = variationKey(variation)
      test(`${key} [${theme}]`, async ({ page }, testInfo) => {
        testInfo.annotations.push(
          { type: 'ur-ui-component', description: variation.component },
          { type: 'ur-ui-variation', description: key },
          { type: 'ur-ui-theme', description: theme },
          { type: 'ur-ui-kind', description: 'conformance' },
        )
        const result: CaseResult = {
          component: variation.component,
          variation: key,
          theme,
          kind: 'conformance',
          failures: [],
          maxDiffPixelRatio: MAX_DIFF_PIXEL_RATIO,
        }
        const referencePage = await page.context().newPage()
        try {
          await Promise.all([
            openReference(referencePage, variation, theme),
            openStorybook(page, variation, theme),
          ])
          const referenceMain = mainLocator(referencePage, variation)
          const storybookMain = storybookMainLocator(page, variation)
          await alignReferenceOrigin(referenceMain, storybookMain)
          await test.step('computed styles', () => checkComputedStyles(referenceMain, storybookMain, result))
          await test.step('screenshot diff', () => checkScreenshots(
            screenshotLocator(referencePage, variation),
            storybookScreenshotLocator(page, variation),
            testInfo,
            result,
          ))
          const slot = variation.screenshotSlot ?? variation.component
          await test.step('reference axe', () => checkAxe(referencePage, `[data-slot="${slot}"]`, 'reference', result))
          await test.step('ur_ui axe', () => checkAxe(page, `#${variation.storyId}`, 'storybook', result))
        } catch (error) {
          result.failures.push({ check: 'infrastructure', message: error instanceof Error ? error.message : String(error) })
          throw error
        } finally {
          await saveCaseResult(testInfo, result)
          await referencePage.close()
        }
      })
    }
  }
})
