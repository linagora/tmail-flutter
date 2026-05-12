# 0087 - Fix Double-Slash Path Normalization for JMAP Session Endpoints

Date: 2026-05-12

## Status

Proposed

## Context

The issue was surfaced during end-to-end (Patrol integration) tests: upload, download, WebSocket ticket, and download-all capability requests were returning 404 on certain server instances.

Root cause: some JMAP servers return session capability URLs with consecutive slashes in the path component (e.g. `http://host//upload/{accountId}`, `wss://host//event/{sessionState}`). RFC 3986 treats `//path` and `/path` as distinct URIs, so the extra slash is forwarded verbatim to the server, which rejects the request with 404.

The project also had two independent implementations of the same normalization logic:

- `Uri.normalizePathSlashes()` in `core/lib/presentation/extensions/uri_extension.dart`
- `String.normalizePathSlashes()` in `core/lib/presentation/extensions/url_extension.dart`

The `RegExp` for multi-slash detection was also instantiated on every call, causing unnecessary recompilation.

## Decision

1. **Single canonical implementation** — keep the regex in `String.normalizePathSlashes()` (`url_extension.dart`) and make `Uri.normalizePathSlashes()` delegate to it:
   ```dart
   Uri normalizePathSlashes() => Uri.parse(toString().normalizePathSlashes());
   ```

2. **Compile the regex once** — promote `RegExp(r'(?<!:)/{2,}')` to a `static final` field in `URLExtension`. The negative lookbehind `(?<!:)` ensures the `://` scheme separator is never collapsed.

3. **Apply normalization at endpoint resolution** — call `normalizePathSlashes()` in four places where session URLs are turned into concrete HTTP/WebSocket requests:
   - `SessionExtension.getUploadUri` (upload endpoint)
   - `SessionExtension.getSafetyDownloadUrl` (download endpoint)
   - `WebSocketTicketCapabilityExtension` (WebSocket ticket endpoint)
   - `DownloadAllCapability.normalizedEndpoint` (download-all capability endpoint)

## Consequences

- ✅ Fixes 404 errors on servers that emit double-slash session URLs
- ✅ Eliminates duplicated regex logic — single source of truth in `url_extension.dart`
- ✅ Regex compiled once per app lifetime instead of once per call
- ✅ No behaviour change for well-formed URLs (idempotent operation)
- ✅ Full unit-test coverage added for the normalization chain: `url_extension`, `uri_extension`, `session_extension`, `download_all_capability`, and `web_socket_ticket_capability_extension`
