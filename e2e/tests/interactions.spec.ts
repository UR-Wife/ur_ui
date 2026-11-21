import { expect, test, type Locator, type Page } from '@playwright/test'
import { variationKey, variations, type Theme, type Variation } from '../shared/variations'
import {
  mainLocator,
  MAX_DIFF_PIXEL_RATIO,
  openReference,
  openStorybook,
  saveCaseResult,
  storybookMainLocator,
  type CaseResult,
} from './helpers'

function byId(page: Page, id: string): Locator {
  return page.locator(`[id=${JSON.stringify(id)}]`)
}

async function checkAccordion(page: Page, root: Locator, variation: Variation) {
  const triggers = root.locator('[data-slot="accordion-trigger"]')
  await expect(triggers.first()).toBeVisible()
  const count = await triggers.count()
  expect(count).toBeGreaterThan(0)
  for (let index = 0; index < count; index++) {
    const trigger = triggers.nth(index)
    await expect(trigger).toHaveRole('button')
    await expect(trigger).toHaveAttribute('aria-expanded', /^(true|false)$/)
    const controls = await trigger.getAttribute('aria-controls')
    if (await trigger.getAttribute('aria-expanded') === 'true') {
      expect(controls, 'expanded accordion trigger needs aria-controls').toBeTruthy()
    }
    if (controls) {
      const content = byId(page, controls)
      const triggerId = await trigger.getAttribute('id')
      expect(triggerId, 'accordion trigger needs an id').toBeTruthy()
      await expect(content).toHaveRole('region')
      await expect(content).toHaveAttribute('aria-labelledby', triggerId!)
    }
  }
  if (variation.variant === 'disabled') await expect(triggers.nth(1)).toBeDisabled()

  const first = triggers.first()
  const initial = await first.getAttribute('aria-expanded')
  await first.focus()
  await page.keyboard.press('Enter')
  await expect(first).not.toHaveAttribute('aria-expanded', initial!)
  await page.keyboard.press('Space')
  await expect(first).toHaveAttribute('aria-expanded', initial!)
}

async function checkTabs(page: Page, root: Locator) {
  await expect(root.getByRole('tablist')).toBeVisible()
  const tabs = root.getByRole('tab')
  const count = await tabs.count()
  expect(count).toBeGreaterThan(0)
  const enabled: number[] = []
  let selected = -1
  for (let index = 0; index < count; index++) {
    const tab = tabs.nth(index)
    if (await tab.isEnabled()) enabled.push(index)
    if (await tab.getAttribute('aria-selected') === 'true') selected = index
    await expect(tab).toHaveAttribute('aria-controls', /.+/)
  }
  expect(selected).toBeGreaterThanOrEqual(0)
  expect(enabled.length).toBeGreaterThan(0)

  const selectedTab = tabs.nth(selected)
  const selectedId = await selectedTab.getAttribute('id')
  const panelId = await selectedTab.getAttribute('aria-controls')
  const panel = byId(page, panelId!)
  await expect(panel).toHaveRole('tabpanel')
  await expect(panel).toBeVisible()
  await expect(panel).toHaveAttribute('aria-labelledby', selectedId!)

  await selectedTab.focus()
  const right = enabled.find((index) => index > selected) ?? enabled[0]
  await page.keyboard.press('ArrowRight')
  await expect(tabs.nth(right)).toHaveAttribute('aria-selected', 'true')
  await expect(tabs.nth(right)).toBeFocused()
  await expect(byId(page, (await tabs.nth(right).getAttribute('aria-controls'))!)).toBeVisible()

  const left = [...enabled].reverse().find((index) => index < right) ?? enabled[enabled.length - 1]
  await page.keyboard.press('ArrowLeft')
  await expect(tabs.nth(left)).toHaveAttribute('aria-selected', 'true')
  await expect(tabs.nth(left)).toBeFocused()
}

for (const component of ['accordion', 'tabs'] as const) {
  test.describe(`${component} keyboard and ARIA`, () => {
    for (const variation of variations.filter((entry) => entry.component === component)) {
      for (const theme of ['light', 'dark'] as Theme[]) {
        const key = variationKey(variation)
        test(`${key} [${theme}]`, async ({ page }, testInfo) => {
          testInfo.annotations.push(
            { type: 'ur-ui-component', description: variation.component },
            { type: 'ur-ui-variation', description: key },
            { type: 'ur-ui-theme', description: theme },
            { type: 'ur-ui-kind', description: 'interaction' },
          )
          const result: CaseResult = {
            component,
            variation: key,
            theme,
            kind: 'interaction',
            failures: [],
            maxDiffPixelRatio: MAX_DIFF_PIXEL_RATIO,
          }
          const referencePage = await page.context().newPage()
          try {
            await Promise.all([
              openReference(referencePage, variation, theme),
              openStorybook(page, variation, theme),
            ])
            for (const side of ['reference', 'storybook'] as const) {
              try {
                if (component === 'accordion') {
                  await checkAccordion(
                    side === 'reference' ? referencePage : page,
                    side === 'reference' ? mainLocator(referencePage, variation) : storybookMainLocator(page, variation),
                    variation,
                  )
                } else {
                  await checkTabs(
                    side === 'reference' ? referencePage : page,
                    side === 'reference' ? mainLocator(referencePage, variation) : storybookMainLocator(page, variation),
                  )
                }
              } catch (error) {
                const message = `${side}: ${error instanceof Error ? error.message : String(error)}`
                result.failures.push({ check: 'interaction', message })
                expect.soft(false, message).toBe(true)
              }
            }
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
}
