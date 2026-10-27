// dwds 25.1.0+2 (Flutter 3.38.9) tears its isolate down 15 s after the last page leaves,
// then no new page runs main (flutter/flutter#178549). Patrol closes its setup page before
// the first test page opens, so this page stays connected for the whole run.
// It opens only after flutter_tools listens for pages: one that connects mid-compile is dropped and never runs main.
const fs = require('fs');
const path = require('path');
const { pathToFileURL, fileURLToPath } = require('url');

const [baseUrl, projectRoot, browserArgsJson, flutterLogPath] = process.argv.slice(2);
const pollMs = 2000;
const deadlineMs = 30 * 60 * 1000;
const mainStartTimeoutMs = 10 * 60 * 1000;
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const readyLine = 'Flutter run key commands.';
const shutdownTimeoutMs = 10 * 1000;
let currentBrowser = null;
let stopping = false;

function playwrightPath() {
  const configDir = path.join(projectRoot, '.dart_tool');
  const config = JSON.parse(fs.readFileSync(path.join(configDir, 'package_config.json'), 'utf8'));
  const patrol = config.packages.find((p) => p.name === 'patrol');
  if (!patrol) throw new Error('patrol not in package_config.json');
  const root = fileURLToPath(new URL(patrol.rootUri, pathToFileURL(configDir + path.sep)));
  return path.join(root, 'web_runner', 'node_modules', '@playwright', 'test');
}

// Resolves true once flutter_tools listens for pages, false at the deadline or on shutdown.
async function waitForFlutterReady(deadline) {
  while (!stopping && Date.now() < deadline) {
    try {
      if (fs.readFileSync(flutterLogPath, 'utf8').includes(readyLine)) return true;
    } catch (e) {
      if (e.code !== 'ENOENT') throw e;
    }
    await sleep(pollMs);
  }
  return false;
}

function shutdown() {
  if (stopping) return;
  stopping = true;
  // browser.close can take up to ~30 s; cleanup must not wait that long
  setTimeout(() => process.exit(0), shutdownTimeoutMs);
  Promise.resolve(currentBrowser && currentBrowser.close())
    .catch(() => {})
    .finally(() => process.exit(0));
}

// Resolves once dwds has connected the page and run its main; the browser stays open.
async function holdPage() {
  // Patrol installs Playwright and its browser only after the dev server is up
  const { chromium } = require(playwrightPath());
  const browser = await chromium.launch({
    args: JSON.parse(browserArgsJson || '[]'),
    // Its own signal handlers close the browser but keep Node alive, so cleanup's wait would block
    handleSIGINT: false,
    handleSIGTERM: false,
    handleSIGHUP: false,
  });
  currentBrowser = browser;
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
    currentBrowser = null;
    await browser.close();
    throw e;
  }
}

// Holds one page until its browser goes away; resolves true if a page was held, false after a failed attempt.
async function holdUntilDisconnected() {
  try {
    const browser = await holdPage();
    console.log(`[keeper] holding ${baseUrl}, app main started`);
    await new Promise((resolve) => browser.on('disconnected', resolve));
    currentBrowser = null;
    if (!stopping) console.error('[keeper] browser disconnected, reopening');
    await sleep(pollMs);
    return true;
  } catch (e) {
    if (!stopping) console.error(`[keeper] not ready: ${e.message.split('\n')[0]}`);
    await sleep(pollMs);
    return false;
  }
}

async function main() {
  if (!flutterLogPath) {
    console.error('[keeper] usage: <baseUrl> <projectRoot> <browserArgsJson> <flutterLogPath>');
    process.exit(2);
  }
  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
  let deadline = Date.now() + deadlineMs;
  if (await waitForFlutterReady(deadline)) {
    console.log('[keeper] flutter_tools ready, opening page');
  }
  while (!stopping && Date.now() < deadline) {
    // A held page restarts the clock, so a late disconnect still gets 30 min of reopen attempts
    if (await holdUntilDisconnected()) deadline = Date.now() + deadlineMs;
  }
  if (stopping) return;
  console.error('[keeper] gave up: no page held for 30 min');
  process.exit(1);
}

main();
