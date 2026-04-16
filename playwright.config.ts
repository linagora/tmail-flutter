import { defineConfig } from '@playwright/test';

// This config ensures headless Chromium (used in CI) has a valid locale,
// preventing Flutter web engine's parseBrowserLanguages from throwing
// "Invalid argument: Incorrect locale information provided".
export default defineConfig({
  use: {
    locale: 'en-US',
    launchOptions: {
      args: ['--lang=en-US'],
    },
  },
});
