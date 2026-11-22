import type { Locator, Page } from '@playwright/test'
import { expect, test } from './ratchet'
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

async function checkTabs(page: Page, root: Locator, variation: Variation) {
  const tabExpectations: Record<string, { label: string; enabled: boolean }[]> = {
    default: [{ label: 'General', enabled: true }, { label: 'Security', enabled: true }],
    default_value: [{ label: 'Plans', enabled: true }, { label: 'Billing', enabled: true }],
    disabled: [{ label: 'General', enabled: true }, { label: 'Advanced', enabled: false }],
  }
  const expectedTabs = tabExpectations[variation.variant]
  if (!expectedTabs) throw new Error(`Expected tab order is not defined for ${variation.variant}`)
  const expectedSelected = variation.variant === 'default_value' ? 1 : 0
  const enabled = expectedTabs.flatMap((tab, index) => tab.enabled ? [index] : [])

  await expect(root.getByRole('tablist')).toBeVisible()
  const tabs = root.getByRole('tab')
  await expect(tabs).toHaveCount(expectedTabs.length)
  const assertExpectedOrder = async () => {
    for (const [index, expected] of expectedTabs.entries()) {
      const tab = tabs.nth(index)
      const labelId = await tab.getAttribute('aria-labelledby')
      if (labelId) {
        await expect(byId(page, labelId)).toHaveText(expected.label)
      } else {
        await expect(tab).toHaveText(expected.label)
      }
      if (expected.enabled) {
        await expect(tab).toBeEnabled()
      } else {
        await expect(tab).toBeDisabled()
        await expect(tab).toHaveAttribute('aria-selected', 'false')
      }
    }
  }
  await assertExpectedOrder()
  await expect(tabs.nth(expectedSelected)).toHaveAttribute('aria-selected', 'true')
  await expect(tabs.nth(expectedSelected)).toHaveAttribute('aria-controls', /.+/)

  const selectedTab = tabs.nth(expectedSelected)
  const selectedId = await selectedTab.getAttribute('id')
  const panelId = await selectedTab.getAttribute('aria-controls')
  const panel = byId(page, panelId!)
  await expect(panel).toHaveRole('tabpanel')
  await expect(panel).toBeVisible()
  await expect(panel).toHaveAttribute('aria-labelledby', selectedId!)

  await selectedTab.focus()
  const right = enabled.find((index) => index > expectedSelected) ?? enabled[0]
  await page.keyboard.press('ArrowRight')
  await expect(tabs.nth(right)).toHaveAttribute('aria-selected', 'true')
  await expect(tabs.nth(right)).toBeFocused()
  await expect(byId(page, (await tabs.nth(right).getAttribute('aria-controls'))!)).toBeVisible()

  const left = [...enabled].reverse().find((index) => index < right) ?? enabled[enabled.length - 1]
  await page.keyboard.press('ArrowLeft')
  await expect(tabs.nth(left)).toHaveAttribute('aria-selected', 'true')
  await expect(tabs.nth(left)).toBeFocused()

  // Home/End jump to the first/last enabled tab (Radix automatic activation).
  for (const [key, index] of [['End', enabled[enabled.length - 1]], ['Home', enabled[0]]] as const) {
    await page.keyboard.press(key)
    await expect(tabs.nth(index)).toHaveAttribute('aria-selected', 'true')
    await expect(tabs.nth(index)).toBeFocused()
    await expect(byId(page, (await tabs.nth(index).getAttribute('aria-controls'))!)).toBeVisible()
  }
  await assertExpectedOrder()
}

async function checkCheckbox(page: Page, root: Locator, variation: Variation) {
  await expect(root).toHaveRole('checkbox')
  const initial = await root.getAttribute('aria-checked')
  expect(initial).toMatch(/^(true|false)$/)

  if (variation.variant === 'disabled') {
    await expect(root).toBeDisabled()
    return
  }

  await root.click()
  await expect(root).not.toHaveAttribute('aria-checked', initial!)
  await root.click()
  await expect(root).toHaveAttribute('aria-checked', initial!)

  await root.focus()
  await page.keyboard.press('Space')
  await expect(root).not.toHaveAttribute('aria-checked', initial!)
  await page.keyboard.press('Space')
  await expect(root).toHaveAttribute('aria-checked', initial!)

  // Enter does not toggle (Radix prevents it).
  await page.keyboard.press('Enter')
  await expect(root).toHaveAttribute('aria-checked', initial!)
}

async function checkCollapsible(page: Page, root: Locator, variation: Variation) {
  const trigger = root.locator('[data-slot="collapsible-trigger"]')
  await expect(trigger).toHaveRole('button')
  const initial = await trigger.getAttribute('aria-expanded')
  expect(initial).toMatch(/^(true|false)$/)

  await trigger.click()
  await expect(trigger).not.toHaveAttribute('aria-expanded', initial!)
  await trigger.click()
  await expect(trigger).toHaveAttribute('aria-expanded', initial!)
}

async function checkRadioGroup(page: Page, root: Locator, variation: Variation) {
  await expect(root).toHaveRole('radiogroup')
  const items = root.getByRole('radio')
  const count = await items.count()
  expect(count).toBeGreaterThan(0)

  let checkedCount = 0
  for (let index = 0; index < count; index++) {
    const value = await items.nth(index).getAttribute('aria-checked')
    expect(value).toMatch(/^(true|false)$/)
    if (value === 'true') checkedCount++
  }
  expect(checkedCount).toBe(1)

  const target = (await items.nth(count - 1).isEnabled()) ? items.nth(count - 1) : items.nth(0)
  await target.click()
  await expect(target).toHaveAttribute('aria-checked', 'true')
}

for (const component of ['accordion', 'tabs', 'checkbox', 'collapsible', 'radio-group'] as const) {
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
                } else if (component === 'tabs') {
                  await checkTabs(
                    side === 'reference' ? referencePage : page,
                    side === 'reference' ? mainLocator(referencePage, variation) : storybookMainLocator(page, variation),
                    variation,
                  )
                } else if (component === 'collapsible') {
                  await checkCollapsible(
                    side === 'reference' ? referencePage : page,
                    side === 'reference' ? mainLocator(referencePage, variation) : storybookMainLocator(page, variation),
                    variation,
                  )
                } else if (component === 'radio-group') {
                  await checkRadioGroup(
                    side === 'reference' ? referencePage : page,
                    side === 'reference' ? mainLocator(referencePage, variation) : storybookMainLocator(page, variation),
                    variation,
                  )
                } else {
                  await checkCheckbox(
                    side === 'reference' ? referencePage : page,
                    side === 'reference' ? mainLocator(referencePage, variation) : storybookMainLocator(page, variation),
                    variation,
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
