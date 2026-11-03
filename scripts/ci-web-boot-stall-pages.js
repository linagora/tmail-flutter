// Usage: node scripts/ci-web-boot-stall-pages.js <web-runner-dir>
const fs = require('fs');
const http = require('http');
const os = require('os');
const path = require('path');
const { cdpEvaluate } = require('./ci-web-boot-stall-cdp');

setTimeout(() => {
  console.log('TIMEOUT CDP diagnostics exceeded 55s');
  process.exit(0);
}, 55000);

// Unreachable profiles are probed together after discovery, so their 9 s of sampling is paid once.
const deferredProbes = [];
const PAGE_WS_SAMPLES = 2;
const PAGE_WS_GAP_MS = Number(process.env.PAGE_WS_GAP_MS || 3000);
const PAGE_WS_TIMEOUT_MS = Number(process.env.PAGE_WS_TIMEOUT_MS || 3000);

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

// Absolute 2s deadline: a socket timeout alone lets a trickling or half-closed response hang.
function getJson(port, route) {
  return new Promise((resolve, reject) => {
    const started = Date.now();
    const req = http.get({ host: '127.0.0.1', port, path: route });
    const timer = setTimeout(() => req.destroy(new Error(`${route} no answer in 2000ms`)), 2000);
    const fail = (error) => { clearTimeout(timer); reject(error); };
    req.on('error', fail);
    req.on('response', (res) => {
      let body = '';
      res.setEncoding('utf8');
      res.on('data', (chunk) => { body += chunk; });
      res.on('error', fail);
      res.on('aborted', () => fail(new Error(`${route} response aborted`)));
      res.on('end', () => {
        clearTimeout(timer);
        if (res.statusCode !== 200) return reject(new Error(`${route} http=${res.statusCode}`));
        try { resolve({ json: JSON.parse(body), ms: Date.now() - started }); } catch (error) { reject(error); }
      });
    });
  });
}

// connectOverCDP attaches every target; the plain HTTP endpoints tell a hung browser from a slow attach.
async function describeUnreachable(dir, port) {
  try {
    const version = await getJson(port, '/json/version');
    console.log(`BROWSER_HTTP ${dir} ok ms=${version.ms} browser=${version.json.Browser}`);
    const list = await getJson(port, '/json/list');
    const targets = Array.isArray(list.json) ? list.json : [];
    console.log(`TARGETS ${dir} ms=${list.ms} total=${targets.length}`);
    targets.forEach((target) => console.log(`TARGET ${dir} id=${target.id} type=${target.type} url=${target.url}`));
    deferredProbes.push({ dir, targets });
  } catch (error) {
    console.log(`BROWSER_HTTP ${dir} fail ${reason(error)}`);
  }
}

// A raw page socket can answer where connectOverCDP cannot attach: no answer means the page itself is unresponsive.
// Two samples show whether `now` and `resources` still advance.
async function probePageTargets(dir, targets, log) {
  const pages = targets.filter((target) => target.type === 'page' && target.webSocketDebuggerUrl
    && !String(target.url).startsWith('about:'));
  const expression = `(${pageBootState.toString()})()`;
  for (let sample = 1; sample <= PAGE_WS_SAMPLES; sample++) {
    if (sample > 1) await new Promise((resolve) => setTimeout(resolve, PAGE_WS_GAP_MS));
    const answers = await Promise.all(pages.map((target) => cdpEvaluate(target.webSocketDebuggerUrl, expression, PAGE_WS_TIMEOUT_MS)));
    answers.forEach((answer, index) => {
      const detail = answer.detail ? ` detail=${answer.detail}` : '';
      log(`PAGE_WS ${dir} id=${pages[index].id} sample=${sample} phase=${answer.phase} result=${answer.result} ms=${answer.ms}${detail}`);
      if (answer.result !== 'ok') return;
      // Another prefix: the probe counts every PAGE line as a tab read through Playwright.
      if (answer.value) printState(answer.value, 'PAGE_WS_STATE', log);
      else log(`PAGE_WS ${dir} id=${pages[index].id} sample=${sample} flutter view present`);
    });
  }
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
    origin: Math.round(performance.timeOrigin),
    pending: scripts.filter((src) => !finished.has(src)),
  };
}

function printState(state, prefix = 'PAGE', log = console.log) {
  log(`${prefix} url=${state.url} readyState=${state.readyState} resources=${state.resources} now=${state.now} origin=${state.origin}`);
  log(`SCRIPTS total=${state.scripts}`);
  // The resource timing buffer holds 250 entries: past that, finished scripts look pending.
  if (state.resources >= 250) log('PENDING_UNRELIABLE resource timing buffer is full');
  state.lastScripts.forEach((src) => log(`LAST_SCRIPT ${src}`));
  log(`PENDING_COUNT ${state.pending.length}`);
  state.pending.slice(0, 20).forEach((src) => log(`PENDING ${src}`));
}

async function inspectPage(dir, page) {
  // A fresh context's blank tab never boots Flutter.
  if (page.url().startsWith('about:')) return;
  try {
    const state = await page.evaluate(pageBootState);
    if (state) printState(state);
  } catch (error) {
    console.log(`SKIP ${dir} page=${page.url()} ${reason(error)}`);
  }
}

async function inspectProfile(chromium, dir) {
  let port = 0;
  try {
    port = readPort(dir);
    const browser = await chromium.connectOverCDP(`http://127.0.0.1:${port}`, { timeout: 5000 });
    const pages = browser.contexts().flatMap((context) => context.pages());
    console.log(`TABS ${dir} total=${pages.length}`);
    for (const page of pages) await inspectPage(dir, page);
  } catch (error) {
    console.log(`SKIP ${dir} ${reason(error)}`);
    if (port) await describeUnreachable(dir, port);
  }
}

async function main() {
  const runnerDir = process.argv[2];
  if (!runnerDir) throw new Error('web-runner-dir missing');
  const { chromium } = require(path.join(path.resolve(runnerDir), 'node_modules', '@playwright', 'test'));
  console.log(`NODE version=${process.version}`);
  const profiles = findProfiles();
  if (!profiles.length) console.log('SKIP no Playwright Chromium profiles');
  for (const dir of profiles) await inspectProfile(chromium, dir);
  const outputs = await Promise.all(deferredProbes.map(async ({ dir, targets }) => {
    const lines = [];
    await probePageTargets(dir, targets, (line) => lines.push(line));
    return lines;
  }));
  outputs.forEach((lines) => lines.forEach((line) => console.log(line)));
}

// Drop CDP sockets without closing the observed browsers or pages.
main().catch((error) => console.log(`SKIP ${process.argv[2] || '<web-runner-dir>'} ${reason(error)}`))
  .finally(() => process.exit(0));
