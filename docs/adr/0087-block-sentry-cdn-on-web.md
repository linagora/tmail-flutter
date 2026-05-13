# 0087. Block Sentry CDN Loading on Web

Date: 2026-05-12

## Status

Accepted

## Context

`sentry_flutter` on web initializes the Sentry JS SDK by dynamically injecting a `<script>` tag pointing to `https://browser.sentry-cdn.com/<version>/bundle.tracing.min.js`. This creates an external network dependency that:

- Violates Content Security Policy in environments that restrict third-party scripts.
- Introduces a CDN availability risk — if `browser.sentry-cdn.com` is unreachable, Sentry initialization fails silently.
- May be blocked by corporate proxies or privacy-focused browser extensions.

The goal is to serve the Sentry JS bundle from the same origin as the app while reliably preventing the package from loading it from CDN at runtime.

## Investigation

### Why `document.createElement` patching does not work

The first fix attempt intercepted CDN loading by overriding `document.createElement('script')`. This approach failed because `sentry_flutter`'s `web_script_dom_api.dart` creates script elements via:

```dart
final script = HTMLScriptElement()  // Dart package:web interop
```

`HTMLScriptElement()` is a native DOM constructor called through Dart's JS interop (`package:web`). It does **not** go through `document.createElement`, so the patch was never triggered and the CDN request was never blocked.

### Why SRI caused a silent outage

The first fix also added `integrity="sha384-..."` and `crossorigin="anonymous"` attributes to the self-hosted scripts. When the deployed file content on the server differed from the hash in `index.html` (deployment drift), the browser blocked both scripts via SRI failure. With neither the self-hosted SDK nor the interceptor loaded, the CDN request went through unblocked — the security mechanism was silently disabled.

For same-origin scripts, SRI provides marginal security value:
- Full-compromise scenario: an attacker who can tamper the JS file can also update the hash in `index.html`.
- MITM scenario: HTTPS already covers this for same-origin resources.

The operational risk (hash staleness disables the entire protection silently) outweighs the security benefit.

## Decision

### 1. Self-host the Sentry JS bundle

Place `bundle.tracing.min.js` (renamed to `sentry-tracing.min.js`) under `web/js/` and load it via a `<script>` tag in `index.html` **before** the Flutter app boots. This pre-populates `window.Sentry` so the Dart SDK can use it without fetching from CDN.

### 2. Patch `HTMLScriptElement.prototype.src` to block CDN injection

Since `sentry_flutter` creates `HTMLScriptElement` instances via the native constructor (bypassing `document.createElement`), the interceptor must patch the **prototype-level `src` setter**. This intercepts `src` assignments on all script elements universally, regardless of how they were created.

```javascript
const nativeSrcDescriptor = Object.getOwnPropertyDescriptor(HTMLScriptElement.prototype, 'src');
Object.defineProperty(HTMLScriptElement.prototype, 'src', {
  configurable: true,
  enumerable: true,
  get: function() { return nativeSrcDescriptor.get.call(this); },
  set: function(val) {
    if (shouldBlockSentryUrl(String(val))) {
      // dispatch synthetic 'load' so the SDK's internal Promise resolves cleanly
      setTimeout(() => this.dispatchEvent(new Event('load')), 10);
      return;
    }
    nativeSrcDescriptor.set.call(this, val);
  },
});
```

`Element.prototype.setAttribute` is also patched as defense-in-depth for the `setAttribute('src', ...)` path.

### 3. Omit SRI for self-hosted scripts

`integrity` and `crossorigin` attributes are intentionally omitted from the two self-hosted `<script>` tags. The rationale:

- SRI for same-origin resources does not protect against the scenarios it is designed for (cross-origin supply-chain attacks, CDN compromise).
- Hash staleness from any deployment drift would silently disable the interceptor — the opposite of the intended behavior.
- HTTPS protects same-origin transport. The server itself is the trust boundary.

If a stronger integrity posture is required in the future, a `Content-Security-Policy: script-src 'self'` header at the server/nginx level is the correct solution — it enforces origin restriction without the fragility of per-file hashes.

### 4. Load order

```html
<!-- index.html -->
<script src="js/sentry-tracing.min.js?v=1.0.0"></script>   <!-- SDK bundle, populates window.Sentry -->
<script src="js/sentry-interceptor.js?v=1.0.1"></script>   <!-- patches prototype, blocks CDN injection -->
<!-- Flutter bootstrap follows -->
```

The interceptor must activate after the SDK bundle so `window.Sentry` is already populated when `SentryFlutter.init()` runs.

## Consequences

- `browser.sentry-cdn.com` is never contacted at runtime — CDN dependency is eliminated.
- Sentry initialization is resilient to CDN availability issues and third-party blockers.
- Updating the Sentry JS bundle version requires replacing `web/js/sentry-tracing.min.js` and bumping the `?v=` query parameter in `index.html`.
- The interceptor is version-independent: it blocks any URL matching `*.sentry-cdn.com/*/bundle.tracing.min.js`, so it does not need to be updated when the SDK version changes.
