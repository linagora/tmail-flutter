// Usage: node scripts/ci-web-boot-stall-pages.js <web-runner-dir>
const fs = require('fs');
const os = require('os');
const path = require('path');

setTimeout(() => {
  console.log('TIMEOUT CDP diagnostics exceeded 30s');
  process.exit(0);
}, 30000);

const reason = (error) => String(error.message || error).split(/\r?\n/)[0];

function listProfiles(base) {
  try {
    return fs.readdirSync(base).filter((name) => name.startsWith('playwright_chromiumdev_profile-'))
      .map((name) => path.join(base, name));
  } catch (_) {
    return [];
  }
}

// Playwright puts the profile under os.tmpdir(); newest first so a live tab is reached before stale dirs.
function findProfiles() {
  return [...new Set([os.tmpdir(), '/tmp'])].flatMap(listProfiles)
    .sort((a, b) => fs.statSync(b).mtimeMs - fs.statSync(a).mtimeMs);
}

function readPort(dir) {
  const port = fs.readFileSync(path.join(dir, 'DevToolsActivePort'), 'utf8').split(/\r?\n/)[0].trim();
  const value = /^\d+$/.test(port) ? Number(port) : 0;
  if (value < 1 || value > 65535) throw new Error('invalid DevToolsActivePort');
  return value;
}

// Runs in the page: null once Flutter has a view, else what the boot still waits on.
function pageBootState() {
  if (document.readyState === 'complete' && document.querySelector('flutter-view, flt-glass-pane')) return null;
  const resources = performance.getEntriesByType('resource');
  const finished = new Set(resources.map((entry) => entry.name));
  const scripts = [...document.scripts].map((script) => script.src).filter(Boolean);
  return {
    url: location.href,
    scripts: scripts.length,
    lastScripts: scripts.slice(-5),
    readyState: document.readyState,
    resources: resources.length,
    now: Math.round(performance.now()),
    pending: scripts.filter((src) => !finished.has(src)),
  };
}

function printState(state) {
  console.log(`PAGE url=${state.url} readyState=${state.readyState} resources=${state.resources} now=${state.now}`);
  console.log(`SCRIPTS total=${state.scripts}`);
  // The resource timing buffer holds 250 entries: past that, finished scripts look pending.
  if (state.resources >= 250) console.log('PENDING_UNRELIABLE resource timing buffer is full');
  state.lastScripts.forEach((src) => console.log(`LAST_SCRIPT ${src}`));
  console.log(`PENDING_COUNT ${state.pending.length}`);
  state.pending.slice(0, 20).forEach((src) => console.log(`PENDING ${src}`));
}

async function inspectPage(dir, page) {
  try {
    const state = await page.evaluate(pageBootState);
    if (state) printState(state);
  } catch (error) {
    console.log(`SKIP ${dir} page=${page.url()} ${reason(error)}`);
  }
}

async function inspectProfile(chromium, dir) {
  try {
    const browser = await chromium.connectOverCDP(`http://127.0.0.1:${readPort(dir)}`, { timeout: 5000 });
    const pages = browser.contexts().flatMap((context) => context.pages());
    console.log(`TABS ${dir} total=${pages.length}`);
    for (const page of pages) await inspectPage(dir, page);
  } catch (error) {
    console.log(`SKIP ${dir} ${reason(error)}`);
  }
}

async function main() {
  const runnerDir = process.argv[2];
  if (!runnerDir) throw new Error('web-runner-dir missing');
  const { chromium } = require(path.join(path.resolve(runnerDir), 'node_modules', '@playwright', 'test'));
  const profiles = findProfiles();
  if (!profiles.length) console.log('SKIP no Playwright Chromium profiles');
  for (const dir of profiles) await inspectProfile(chromium, dir);
}

// Drop CDP sockets without closing the observed browsers or pages.
main().catch((error) => console.log(`SKIP ${process.argv[2] || '<web-runner-dir>'} ${reason(error)}`))
  .finally(() => process.exit(0));
