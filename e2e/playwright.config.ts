import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './tests',
  outputDir: './test-results',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: process.env.CI ? 2 : 4,
  timeout: 60_000,
  expect: {
    timeout: 10_000,
    toHaveScreenshot: { maxDiffPixelRatio: 0.02 },
  },
  reporter: [
    ['list'],
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
    ['json', { outputFile: 'results/results.json' }],
  ],
  use: {
    baseURL: 'http://127.0.0.1:4173',
    browserName: 'chromium',
    viewport: { width: 1280, height: 900 },
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [{ name: 'chromium', use: { browserName: 'chromium' } }],
  webServer: [
    {
      command: 'npm --prefix reference run preview -- --host 127.0.0.1 --port 4173',
      url: 'http://127.0.0.1:4173/button/destructive',
      cwd: '.',
      reuseExistingServer: !process.env.CI,
      timeout: 30_000,
    },
    {
      command: 'mix phx.server',
      url: 'http://127.0.0.1:4000/storybook/ur_ui/button',
      cwd: '..',
      reuseExistingServer: !process.env.CI,
      timeout: 120_000,
    },
  ],
})
