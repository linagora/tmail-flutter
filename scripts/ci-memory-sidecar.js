// Memory sidecar for scripts/memory-leak-check.sh. Needs Node 20 with --experimental-websocket.
//   POST /sample                    Android: stores the Dart allocation profile JSON.
//   POST /snapshot?case=&label=     Web: takes a V8 heap snapshot of the page tagged with <case> over CDP.
const fs = require('fs');
const http = require('http');
const path = require('path');

const OUT_DIR = process.env.MEMORY_OUT_DIR || path.join(process.cwd(), 'ci-logs', 'memory');
const CDP_PORT = process.env.MEMORY_CDP_PORT || '9333';
const PORT = Number(process.env.MEMORY_SIDECAR_PORT || 9998);
const SNAPSHOT_TIMEOUT_MS = 110000;
const SAFE_NAME = /^[A-Za-z0-9_-]+$/;
const isSafeName = (value) => SAFE_NAME.test(value || '');

if (typeof WebSocket === 'undefined') {
  console.error('WebSocket is missing: run with node --experimental-websocket');
  process.exit(1);
}
fs.mkdirSync(OUT_DIR, { recursive: true });

function getJson(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      let body = '';
      res.on('data', (chunk) => { body += chunk; });
      res.on('end', () => { try { resolve(JSON.parse(body)); } catch (error) { reject(error); } });
    }).on('error', reject);
  });
}

function openCdp(wsUrl) {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(wsUrl);
    const pending = new Map();
    const listeners = [];
    let nextId = 0;
    ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      if (message.id && pending.has(message.id)) {
        const { res, rej } = pending.get(message.id);
        pending.delete(message.id);
        if (message.error) rej(new Error(JSON.stringify(message.error)));
        else res(message.result);
      } else if (message.method) {
        listeners.forEach((listener) => listener(message));
      }
    };
    ws.onerror = () => reject(new Error('CDP websocket error'));
    ws.onopen = () => resolve({
      send: (method, params = {}) => new Promise((res, rej) => {
        const id = ++nextId;
        pending.set(id, { res, rej });
        ws.send(JSON.stringify({ id, method, params }));
      }),
      onEvent: (listener) => listeners.push(listener),
      close: () => ws.close(),
    });
  });
}

// The page tags itself with globalThis.__tmailMemoryProbeId = <case>; other tabs are skipped.
async function findPage(caseId) {
  const targets = await getJson(`http://127.0.0.1:${CDP_PORT}/json/list`);
  const pages = targets.filter((target) => target.type === 'page'
    && target.webSocketDebuggerUrl && !String(target.url).startsWith('about:'));
  for (const page of pages) {
    const cdp = await openCdp(page.webSocketDebuggerUrl);
    try {
      const result = await cdp.send('Runtime.evaluate', {
        expression: 'globalThis.__tmailMemoryProbeId', returnByValue: true,
      });
      if (result.result && result.result.value === caseId) return cdp;
    } catch (_) { /* not this tab */ }
    cdp.close();
  }
  return null;
}

async function takeSnapshot(cdp, file) {
  const out = fs.createWriteStream(file);
  cdp.onEvent((message) => {
    if (message.method === 'HeapProfiler.addHeapSnapshotChunk') out.write(message.params.chunk);
  });
  try {
    await cdp.send('HeapProfiler.enable');
    await cdp.send('HeapProfiler.collectGarbage');
    await cdp.send('HeapProfiler.collectGarbage');
    await cdp.send('HeapProfiler.takeHeapSnapshot', { reportProgress: false });
  } finally {
    await new Promise((resolve) => out.end(resolve));
    cdp.close();
  }
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', (chunk) => chunks.push(chunk));
    req.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
    req.on('error', reject);
  });
}

function reply(res, status, text) {
  if (res.headersSent) return;
  res.writeHead(status);
  res.end(text);
}

async function handleSample(req, res) {
  const sample = JSON.parse(await readBody(req));
  if (!isSafeName(sample.case) || !isSafeName(sample.label)) return reply(res, 400, 'bad case/label');
  fs.writeFileSync(path.join(OUT_DIR, `${sample.case}-${sample.label}.android.json`), JSON.stringify(sample));
  return reply(res, 200, 'ok');
}

async function handleSnapshot(url, res) {
  const caseId = url.searchParams.get('case');
  const label = url.searchParams.get('label');
  if (!isSafeName(caseId) || !isSafeName(label)) return reply(res, 400, 'bad case/label');
  const cdp = await findPage(caseId);
  if (!cdp) return reply(res, 404, `no page tagged ${caseId}`);
  await takeSnapshot(cdp, path.join(OUT_DIR, `${caseId}-${label}.heapsnapshot`));
  return reply(res, 200, 'ok');
}

const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', '*');
  if (req.method === 'OPTIONS') return reply(res, 204, '');
  const url = new URL(req.url, 'http://localhost');
  const timer = setTimeout(() => reply(res, 504, `no answer in ${SNAPSHOT_TIMEOUT_MS} ms`), SNAPSHOT_TIMEOUT_MS);
  try {
    if (req.method === 'POST' && url.pathname === '/sample') await handleSample(req, res);
    else if (req.method === 'POST' && url.pathname === '/snapshot') await handleSnapshot(url, res);
    else reply(res, 404, 'not found');
  } catch (error) {
    console.error('sidecar error', error);
    reply(res, 500, String(error.message || error));
  } finally {
    clearTimeout(timer);
  }
});
server.listen(PORT, '127.0.0.1', () => console.log(`memory sidecar on ${PORT}, output ${OUT_DIR}`));
