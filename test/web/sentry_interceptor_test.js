const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const vm = require('node:vm');

const webJs = path.resolve(__dirname, '../../web/js');
const sentryBundle = readFileSync(path.join(webJs, 'sentry-tracing.min.js'), 'utf8');
const interceptor = readFileSync(path.join(webJs, 'sentry-interceptor.js'), 'utf8');

class Element {
  setAttribute(name, value) {
    if (name === 'src') this.src = value;
  }
}

function createScriptElementClass(externalScripts) {
  class HTMLScriptElement extends Element {
    constructor() {
      super();
      this.listeners = new Map();
    }

    addEventListener(name, listener) {
      const listeners = this.listeners.get(name) || [];
      listeners.push(listener);
      this.listeners.set(name, listeners);
    }

    dispatchEvent(event) {
      for (const listener of this.listeners.get(event.type) || []) {
        listener(event);
      }
    }
  }

  Object.defineProperty(HTMLScriptElement.prototype, 'src', {
    configurable: true,
    get() { return this._src; },
    set(value) {
      this._src = value;
      externalScripts.push(value);
    },
  });

  return HTMLScriptElement;
}

function createPage() {
  const externalScripts = [];
  const page = {
    console: { log() {}, warn() {} },
    setTimeout,
    clearTimeout,
    setInterval,
    clearInterval,
    setImmediate,
    URL,
    URLSearchParams,
    TextEncoder,
    TextDecoder,
    performance,
    Promise,
    Element,
    HTMLScriptElement: createScriptElementClass(externalScripts),
    Event: class Event {
      constructor(type) { this.type = type; }
    },
    document: {
      baseURI: 'https://mail.example.test/',
      addEventListener() {},
      removeEventListener() {},
    },
    location: { href: 'https://mail.example.test/' },
    navigator: { userAgent: 'test' },
  };
  page.window = page;
  page.globalThis = page;
  vm.createContext(page);
  vm.runInContext(sentryBundle, page);
  vm.runInContext(interceptor, page);
  return { page, externalScripts };
}

function createSentryOptions(sentEnvelopes) {
  return {
    dsn: 'https://public@example.test/1',
    defaultIntegrations: [],
    transport: () => ({
      send: envelope => {
        sentEnvelopes.push(envelope);
        return Promise.resolve({ statusCode: 200 });
      },
      flush: () => Promise.resolve(true),
    }),
  };
}

function loadFlutterSdkScript(HTMLScriptElement) {
  return new Promise(resolve => {
    const script = new HTMLScriptElement();
    script.addEventListener('load', resolve);
    script.src = 'https://browser.sentry-cdn.com/10.6.0/bundle.tracing.min.js';
  });
}

test('Sentry reports again after web consent is turned off and on', async () => {
  const { page, externalScripts } = createPage();
  const sentEnvelopes = [];
  const sentry = page.Sentry;
  const options = createSentryOptions(sentEnvelopes);

  await loadFlutterSdkScript(page.HTMLScriptElement);
  sentry.init(options);
  sentry.captureMessage('first opt-in');
  await new Promise(setImmediate);
  assert.equal(sentEnvelopes.length, 1);

  await sentry.close();
  page.Sentry = null; // sentry_flutter's WebSentryJsBinding.close()
  sentry.captureMessage('while opted out');
  await new Promise(setImmediate);
  assert.equal(sentEnvelopes.length, 1);

  await loadFlutterSdkScript(page.HTMLScriptElement);
  assert.ok(page.Sentry, 'interceptor must restore the local SDK on re-init');
  assert.equal(page.Sentry, sentry);
  page.Sentry.init(options);
  page.Sentry.captureMessage('second opt-in');
  await new Promise(setImmediate);

  assert.equal(sentEnvelopes.length, 2);
  assert.deepEqual(externalScripts, []);
  await page.Sentry.close();
});
