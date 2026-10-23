// dwds 25.1.0+2 (Flutter 3.38.9) tears its isolate down 15 s after the last page leaves,
// then no new page runs main (flutter/flutter#178549). Patrol closes its setup page before
// the first test page opens, so this page stays connected for the whole run.
const fs = require('fs');
const path = require('path');
const { pathToFileURL, fileURLToPath } = require('url');

const [baseUrl, projectRoot, browserArgsJson] = process.argv.slice(2);
const pollMs = 2000;
const deadlineMs = 30 * 60 * 1000;
const mainStartTimeoutMs = 10 * 60 * 1000;
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

function playwrightPath() {
  const configDir = path.join(projectRoot, '.dart_tool');
  const config = JSON.parse(fs.readFileSync(path.join(configDir, 'package_config.json'), 'utf8'));
  const patrol = config.packages.find((p) => p.name === 'patrol');
  if (!patrol) throw new Error('patrol not in package_config.json');
  const root = fileURLToPath(new URL(patrol.rootUri, pathToFileURL(configDir + path.sep)));
  return path.join(root, 'web_runner', 'node_modules', '@playwright', 'test');
}

// Resolves once dwds has connected the page and run its main; the browser stays open.
async function holdPage() {
  // Patrol installs Playwright and its browser only after the dev server is up
  const { chromium } = require(playwrightPath());
  const browser = await chromium.launch({ args: JSON.parse(browserArgsJson || '[]') });
  try {
    const page = await browser.newPage();
    const mainStarted = page.waitForEvent('console', {
      predicate: (msg) => msg.text().startsWith('Starting application'),
      timeout: mainStartTimeoutMs,
    });
    // Closing the browser on a failed goto rejects this promise with no awaiter left
    mainStarted.catch(() => {});
    const response = await page.goto(baseUrl);
    if (!response || !response.ok()) throw new Error(`HTTP ${response && response.status()}`);
    await mainStarted;
    return browser;
  } catch (e) {
    await browser.close();
    throw e;
  }
}

async function main() {
  const start = Date.now();
  while (Date.now() - start < deadlineMs) {
    try {
      const browser = await holdPage();
      console.log(`[keeper] holding ${baseUrl}, app main started`);
      await new Promise((resolve) => browser.on('disconnected', resolve));
      console.error('[keeper] browser disconnected, reopening');
    } catch (e) {
      console.error(`[keeper] not ready: ${e.message.split('\n')[0]}`);
      await sleep(pollMs);
    }
  }
  console.error('[keeper] gave up after 30 min');
  process.exit(1);
}

main();
