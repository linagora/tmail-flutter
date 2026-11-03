// Dependency-free DevTools WebSocket client: Node < 22 has no global WebSocket,
// and Playwright's own attach is the call that hangs on a stalled browser.
const crypto = require('crypto');
const http = require('http');

const reason = (error) => String(error.message || error).split(/\r?\n/)[0];

function encodeTextFrame(text) {
  const payload = Buffer.from(text);
  const mask = crypto.randomBytes(4);
  let header;
  if (payload.length < 126) {
    header = Buffer.from([0x81, 0x80 | payload.length]);
  } else if (payload.length < 65536) {
    header = Buffer.from([0x81, 0x80 | 126, payload.length >> 8, payload.length & 0xff]);
  } else {
    header = Buffer.alloc(10);
    header[0] = 0x81;
    header[1] = 0x80 | 127;
    header.writeBigUInt64BE(BigInt(payload.length), 2);
  }
  const masked = Buffer.from(payload);
  for (let i = 0; i < masked.length; i++) masked[i] ^= mask[i % 4];
  return Buffer.concat([header, mask, masked]);
}

// Header size and payload length of the frame at `offset`; null while the header is incomplete.
function readFrameHeader(buffer, offset) {
  const available = buffer.length - offset;
  const short = buffer[offset + 1] & 0x7f;
  if (short < 126) return { header: 2, length: short };
  if (short === 126) return available < 4 ? null : { header: 4, length: buffer.readUInt16BE(offset + 2) };
  return available < 10 ? null : { header: 10, length: Number(buffer.readBigUInt64BE(offset + 2)) };
}

// Server frames are unmasked; an incomplete trailing frame stays in `rest`.
function readFrames(buffer) {
  const frames = [];
  let offset = 0;
  while (buffer.length - offset >= 2) {
    const size = readFrameHeader(buffer, offset);
    if (!size || buffer.length - offset < size.header + size.length) break;
    const start = offset + size.header;
    frames.push({
      fin: (buffer[offset] & 0x80) !== 0,
      opcode: buffer[offset] & 0x0f,
      payload: buffer.subarray(start, start + size.length),
    });
    offset = start + size.length;
  }
  return { frames, rest: buffer.subarray(offset) };
}

// Feeds socket bytes in; calls onText per complete text message and onClose on a close frame.
function createFrameStream(onText, onClose) {
  let pending = Buffer.alloc(0);
  let text = '';
  const onFrame = (frame) => {
    if (frame.opcode === 8) return onClose();
    // Only text (1) and its continuations (0) carry replies; ping, pong and binary are ignored.
    if (frame.opcode > 1) return;
    text += frame.payload.toString('utf8');
    if (!frame.fin) return;
    const complete = text;
    text = '';
    onText(complete);
  };
  return (chunk) => {
    const parsed = readFrames(Buffer.concat([pending, chunk]));
    pending = parsed.rest;
    parsed.frames.forEach(onFrame);
  };
}

// [result, extra] for the reply to our request (id 1); null for any other message.
function outcomeOf(message) {
  if (message.id !== 1) return null;
  if (message.error) return ['error', { detail: reason(message.error.message) }];
  const details = message.result.exceptionDetails;
  if (details) return ['error', { detail: reason((details.exception && details.exception.description) || details.text) }];
  return ['ok', { value: message.result.result.value }];
}

function handleReply(text, finish) {
  try {
    const outcome = outcomeOf(JSON.parse(text));
    if (outcome) finish(...outcome);
  } catch (error) {
    finish('error', { detail: reason(error) });
  }
}

function startSession(socket, head, expression, finish) {
  const onData = createFrameStream((text) => handleReply(text, finish), () => finish('closed'));
  socket.on('data', onData);
  socket.on('error', (error) => finish('error', { detail: reason(error) }));
  socket.on('close', () => finish('closed'));
  socket.write(encodeTextFrame(JSON.stringify({
    id: 1,
    method: 'Runtime.evaluate',
    params: { expression, returnByValue: true },
  })));
  if (head.length) onData(head);
}

function handshakeOptions(url) {
  return {
    host: '127.0.0.1',
    port: url.port,
    path: url.pathname + url.search,
    headers: {
      Connection: 'Upgrade',
      Upgrade: 'websocket',
      'Sec-WebSocket-Key': crypto.randomBytes(16).toString('base64'),
      'Sec-WebSocket-Version': '13',
    },
  };
}

// Resolves (never rejects) with { phase: connect|eval, result: ok|timeout|error|closed, ms, value?, detail? }.
function cdpEvaluate(wsUrl, expression, timeoutMs) {
  return new Promise((resolve) => {
    const started = Date.now();
    let phase = 'connect';
    let socket = null;
    let req = null;
    let settled = false;
    const finish = (result, extra = {}) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      if (socket) socket.destroy();
      if (req) req.destroy();
      resolve({ phase, result, ms: Date.now() - started, ...extra });
    };
    const timer = setTimeout(() => finish('timeout'), timeoutMs);
    try {
      req = http.request(handshakeOptions(new URL(wsUrl)));
    } catch (error) {
      return finish('error', { detail: reason(error) });
    }
    req.on('error', (error) => finish('error', { detail: reason(error) }));
    req.on('response', (res) => finish('error', { detail: `handshake http=${res.statusCode}` }));
    req.on('upgrade', (res, upgraded, head) => {
      if (settled) return upgraded.destroy();
      socket = upgraded;
      phase = 'eval';
      startSession(upgraded, head, expression, finish);
    });
    req.end();
  });
}

module.exports = { cdpEvaluate, encodeTextFrame, createFrameStream, handshakeOptions };
