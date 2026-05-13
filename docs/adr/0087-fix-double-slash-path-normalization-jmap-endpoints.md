# 0087 - Fix Double-Slash Path Normalization for JMAP Session Endpoints

Date: 2026-05-12

## Status

Proposed

## Context

Some JMAP servers return session capability URLs with consecutive slashes (e.g. `http://host//upload/{accountId}`). RFC 3986 treats `//path` and `/path` as distinct, so the extra slash is forwarded verbatim, causing 404s on upload, download, WebSocket ticket, and download-all requests.

The project also had two independent regex-based implementations of the same normalization, with the `RegExp` re-instantiated on every call.

## Decision

1. **Single canonical implementation** — keep the regex in `String.normalizePathSlashes()` (`url_extension.dart`) and delegate from `Uri.normalizePathSlashes()`:
   ```dart
   Uri normalizePathSlashes() => replace(path: path.normalizePathSlashes());
   ```

2. **Compile the regex once** — promote `RegExp(r'(?<!:)/{2,}')` to a `static final` field in `URLExtension`. The negative lookbehind `(?<!:)` ensures `://` is never collapsed.

3. **Apply normalization at endpoint resolution** — call `normalizePathSlashes()` in four places:
   - `SessionExtension.getUploadUri`
   - `SessionExtension.getSafetyDownloadUrl`
   - `WebSocketTicketCapabilityExtension.normalizedGenerationEndpoint`
   - `DownloadAllCapability.normalizedEndpoint`

## Consequences

- Fixes 404 errors caused by double-slash session URLs
- Single normalization source of truth; regex compiled once per app lifetime
- No behaviour change for well-formed URLs (idempotent)
- Full unit-test coverage for the normalization chain
