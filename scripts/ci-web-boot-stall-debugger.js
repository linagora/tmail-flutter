// Usage: node scripts/ci-web-boot-stall-debugger.js <profile-dir>
// A tab whose renderer froze answers neither Playwright nor Runtime.evaluate. This asks the browser process,
// which still answers, why: waitingForDebugger on attach and a Debugger.paused event tell an inspector
// suspension from a renderer stuck in native code. It only observes; a resume or run command could end the
// stall before the native stacks of the frozen renderer are captured.
const fs = require('fs');
const http = require('http');
const path = require('path');
const { encodeTextFrame, createFrameStream, handshakeOptions } = require('./ci-web-boot-stall-cdp');

const COMMAND_TIMEOUT_MS = Number(process.env.DEBUGGER_COMMAND_TIMEOUT_MS || 3000);
const SETTLE_MS = Number(process.env.DEBUGGER_SETTLE_MS || 1000);
const MAX_PAGES = 2;
const dir = process.argv[2];

const reason = (error) => String(error.message || error).split(/\r?\n/)[0];
const log = (step, result, extra = '') => console.log(`DBG ${dir} ${step} ${result}${extra ? ` ${extra}` : ''}`);

if (!dir) {
  console.log('DBG usage: ci-web-boot-stall-debugger.js <profile-dir>');
  process.exit(0);
}

setTimeout(() => {
  log('deadline', 'exceeded 20s');
  process.exit(0);
}, 20000).unref();

function readEndpoint() {
  const [port, browserPath] = fs.readFileSync(path.join(dir, 'DevToolsActivePort'), 'utf8').split(/\r?\n/);
  if (!/^\d+$/.test(port) || !browserPath) throw new Error('invalid DevToolsActivePort');
  return `ws://127.0.0.1:${port}${browserPath}`;
}

// Browser-level socket: commands resolve with { result: ok|error|timeout, message, ms }; events pile up in `events`.
function openClient(wsUrl) {
  return new Promise((resolve, reject) => {
    const replies = new Map();
    const events = [];
    let lastId = 0;
    const onText = (text) => {
      let message;
      try { message = JSON.parse(text); } catch (_) { return; }
      if (message.id && replies.has(message.id)) replies.get(message.id)(message);
      else if (message.method) events.push(message);
    };
    const req = http.request(handshakeOptions(new URL(wsUrl)));
    req.on('error', reject);
    req.on('response', (res) => reject(new Error(`handshake http=${res.statusCode}`)));
    req.on('upgrade', (res, socket, head) => {
      const feed = createFrameStream(onText, () => socket.destroy());
      socket.on('data', feed);
      socket.on('error', () => {});
      if (head.length) feed(head);
      const send = (method, params = {}, sessionId) => new Promise((done) => {
        const id = ++lastId;
        const started = Date.now();
        const finish = (result, message) => {
          clearTimeout(timer);
          replies.delete(id);
          done({ result, message, ms: Date.now() - started });
        };
        const timer = setTimeout(() => finish('timeout'), COMMAND_TIMEOUT_MS);
        replies.set(id, (message) => finish(message.error ? 'error' : 'ok', message));
        socket.write(encodeTextFrame(JSON.stringify(sessionId ? { id, method, params, sessionId } : { id, method, params })));
      });
      resolve({ send, events, close: () => socket.destroy() });
    });
    req.end();
  });
}

function report(step, answer) {
  const detail = answer.result === 'error' ? ` detail=${reason(answer.message.error)}` : '';
  log(step, answer.result, `ms=${answer.ms}${detail}`);
}

function describePause({ params }) {
  const [frame] = params.callFrames ?? [];
  return `reason=${params.reason} top=${frame?.url ?? 'unknown'}:${frame?.location?.lineNumber ?? '?'}`;
}

function reportAttachEvent(client, sessionId) {
  const attached = client.events.find((e) => e.method === 'Target.attachedToTarget' && e.params.sessionId === sessionId);
  if (!attached) return log('Target.attachedToTarget', 'missing');
  log('Target.attachedToTarget', 'event', `waitingForDebugger=${attached.params.waitingForDebugger}`);
}

function reportPause(client, sessionId) {
  const paused = client.events.find((e) => e.method === 'Debugger.paused' && e.sessionId === sessionId);
  if (!paused) return log('Debugger.paused', 'none');
  log('Debugger.paused', 'event', describePause(paused));
}

async function inspectPage(client, target) {
  log('target', 'page', `id=${target.targetId} url=${target.url}`);
  const attach = await client.send('Target.attachToTarget', { targetId: target.targetId, flatten: true });
  report('Target.attachToTarget', attach);
  const sessionId = attach.message?.result?.sessionId;
  if (!sessionId) return;
  reportAttachEvent(client, sessionId);
  report('Debugger.enable', await client.send('Debugger.enable', {}, sessionId));
  // The pause event may arrive before or after the reply to Debugger.enable.
  await new Promise((resolve) => setTimeout(resolve, SETTLE_MS));
  reportPause(client, sessionId);
  report('Runtime.evaluate', await client.send('Runtime.evaluate', { expression: '1', returnByValue: true }, sessionId));
  await client.send('Target.detachFromTarget', { sessionId });
}

async function main() {
  const client = await openClient(readEndpoint());
  try {
    const targets = await client.send('Target.getTargets');
    report('Target.getTargets', targets);
    const infos = targets.message?.result?.targetInfos ?? [];
    const pages = infos.filter((info) => info.type === 'page' && !String(info.url).startsWith('about:')).slice(0, MAX_PAGES);
    if (!pages.length) log('pages', 'none');
    for (const page of pages) await inspectPage(client, page);
  } finally {
    client.close();
  }
}

main().catch((error) => log('probe', 'error', reason(error))).finally(() => process.exit(0));
