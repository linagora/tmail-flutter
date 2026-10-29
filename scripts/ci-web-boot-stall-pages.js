// Usage: node scripts/ci-web-boot-stall-pages.js <web-runner-dir>
const fs = require('fs');
const os = require('os');
const path = require('path');

setTimeout(() => {
  console.log('TIMEOUT CDP diagnostics exceeded 30s');
  process.exit(0);
}, 30000);

const reason = (error) => String(error.message || error).split(/\r?\n/)[0];

async function main() {
  const runnerDir = process.argv[2];
  if (!runnerDir) throw new Error('web-runner-dir missing');
  const { chromium } = require(path.join(path.resolve(runnerDir), 'node_modules', '@playwright', 'test'));
  // Playwright puts the profile under os.tmpdir(); newest first so a live tab is reached before stale dirs.
  const profiles = [...new Set([os.tmpdir(), '/tmp'])].flatMap((base) => {
    try {
      return fs.readdirSync(base).filter((name) => name.startsWith('playwright_chromiumdev_profile-'))
        .map((name) => path.join(base, name));
    } catch (_) {
      return [];
    }
  }).sort((a, b) => fs.statSync(b).mtimeMs - fs.statSync(a).mtimeMs);
  if (!profiles.length) console.log('SKIP no Playwright Chromium profiles');
  for (const dir of profiles) {
    try {
      const port = fs.readFileSync(path.join(dir, 'DevToolsActivePort'), 'utf8').split(/\r?\n/)[0].trim();
      if (!/^\d+$/.test(port) || Number(port) < 1 || Number(port) > 65535) {
        throw new Error('invalid DevToolsActivePort');
      }
      const browser = await chromium.connectOverCDP(`http://127.0.0.1:${port}`, { timeout: 5000 });
      const tabs = browser.contexts().flatMap((context) => context.pages());
      console.log(`TABS ${dir} total=${tabs.length}`);
      for (const context of browser.contexts()) {
        for (const page of context.pages()) {
          try {
            const state = await page.evaluate(() => {
              if (document.readyState === 'complete') return null;
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
            });
            if (!state) continue;
            console.log(`PAGE url=${state.url} readyState=${state.readyState} resources=${state.resources} now=${state.now}`);
            console.log(`SCRIPTS total=${state.scripts}`);
            // The resource timing buffer holds 250 entries: past that, finished scripts look pending.
            if (state.resources >= 250) console.log('PENDING_UNRELIABLE resource timing buffer is full');
            for (const src of state.lastScripts) console.log(`LAST_SCRIPT ${src}`);
            console.log(`PENDING_COUNT ${state.pending.length}`);
            for (const src of state.pending.slice(0, 20)) console.log(`PENDING ${src}`);
          } catch (error) {
            console.log(`SKIP ${dir} page=${page.url()} ${reason(error)}`);
          }
        }
      }
    } catch (error) {
      console.log(`SKIP ${dir} ${reason(error)}`);
    }
  }
}

// Drop CDP sockets without closing the observed browsers or pages.
main().catch((error) => console.log(`SKIP ${process.argv[2] || '<web-runner-dir>'} ${reason(error)}`))
  .finally(() => process.exit(0));
