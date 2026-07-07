# 103. Attach Drive File as Attachment

Date: 2026-07-07

## Status

Proposed

## Reference
Builds on [ADR-0095](0095-external-drive-file-picker-integration.md) (intent protocol, `DriveDocument` entity, link-only insertion).

## Context

Composer already inserts picked drive documents with a `sharingLink` as HTML links. Documents with a `downloadLink` instead need to be downloaded and attached as real email attachments.

## Decision

**Partitioning:** `DriveAttachmentHandler` splits picked `DriveDocument`s per-doc: `sharingLink != null` → HTML link (unchanged); `downloadLink != null` → download + attach (new).

**Download (`workplace` package), streamed:** `DriveFileDatasourceImpl.openFileForUpload(doc)` branches on `kIsWeb`. **IO**: `Dio.get(responseType: stream)` piped directly as the upload request body (`FileInfo.byteStream`) — true zero-copy, no whole-file buffering, backpressure handled automatically by Dio. **Web**: `BrowserHttpClientAdapter` (XHR) can't stream a body, so web still buffers into `FileInfo.bytes`. `DownloadDriveFileInteractor.openFileForUpload` is a thin future delegate (no more stream-of-states). A bounded worker pool (`kMaxConcurrentDriveTransfers = 3`) runs per-file pipelines: file N+1 starts downloading as a slot frees, and each file starts uploading the instant its own stream is ready (no "download all, then upload all" batching). A failing file logs/removes its chip; others continue.

**Visible progress:** each drive file gets a composer attachment chip immediately (`UploadFileStatus.downloading`, color-distinct from `uploading`), fed by `onDownloadProgress`/Dio's existing `onSendProgress`. On IO, download+upload are coupled in lockstep by the pipe, so the chip shows one continuous "downloading"-styled bar for ~the whole transfer (single phase, zero-copy memory kept over a two-phase visual). On web, downloading and uploading are genuinely sequential — two distinct phases shown.

**Validation — minimal, condition-agnostic abstraction:**
```dart
abstract class AttachmentUploadValidator {
  FutureOr<bool> validate();
}

class CompositeAttachmentUploadValidator implements AttachmentUploadValidator {
  final List<AttachmentUploadValidator> validators;
  const CompositeAttachmentUploadValidator(this.validators);

  @override
  Future<bool> validate() async {
    if (validators.isEmpty) return true;
    for (final v in validators) {
      if (!await v.validate()) return false;
    }
    return true;
  }
}
```
No size (or other condition-specific data) in the interface. Each concrete validator captures what it needs via its own constructor and is fully self-contained, including showing its own dialog. Today's only concrete validator, `SizeLimitAttachmentUploadValidator`, wraps the existing size-limit/warning-dialog check. Every attachment entry point (composer's local-file/paste/drop handlers, `DriveAttachmentHandler`) constructs the validator(s) it needs and calls `.validate()` — no cross-controller dependency. A new, unrelated condition later = one new class + one line in a `CompositeAttachmentUploadValidator([...])` list.

**Upload (reused as-is):** downloaded/picked `FileInfo`s all go through the composer's existing single upload trigger (session/account resolution → JMAP upload URI → chunked upload). Drive attachments are indistinguishable from local ones past this point.

**Module boundary:** intent protocol, `DriveDocument`, and the download chain stay in `workplace`; only `DriveAttachmentHandler` (main app) composes download orchestration with the shared validator abstraction and the composer's existing upload trigger.

## Consequences
- Drive attachments reuse the exact same size-limit UX and upload pipeline as every other attachment source; `FileInfo` gains an additive, transient `byteStream` field so the rest of the upload machinery (interactor/repository/`FileUploader`) is unchanged.
- A new attachment-eligibility condition is one new class + one line, not a change to every call site.
- Memory stays flat on IO regardless of file size/concurrent count (zero-copy pipe); web still buffers per file (XHR limitation).
- User sees live per-file progress immediately instead of a blocking wait.
- A streamed IO upload isn't 401-retry-safe (one-shot tee body can't be rebuilt) — accepted, that file's chip fails and is removed, others continue.

## Risks
- IO shows only a single-phase "downloading"-styled bar for the whole transfer (download/upload are coupled in lockstep) — accepted over forcing IO to buffer for a two-phase visual.
- Stream receive-timeout is uncapped (`Duration.zero`); a stalled server relies on the user's manual cancel action. **Correction after checking Dio's actual IO adapter source (pinned `dio: 5.2.0`, and current 5.9.0):** `receiveTimeout` was never a whole-transfer watchdog on IO in the first place — it only guards time-to-first-byte/headers (`request.close()`), so the 10s default wasn't going to "kill a slow transfer mid-stream" either way. Setting `Duration.zero` still avoids a spurious timeout before a slow drive file starts streaming, just not for the reason originally stated.
- Concurrency fixed at 3 concurrent transfers, not user/config-configurable (YAGNI for now).
- **Web buffering is a browser platform limit, not a Dio-specific gap.** Verified via `dio_web_adapter` 2.1.1 source (current, ships with `dio: 5.9.0`) — still XHR-based, still fully buffers the request stream before `xhr.send()`. A hand-rolled `fetch()` client wouldn't help either: streaming *upload* request bodies only works on Chromium (Chrome/Edge/Opera, v105+, and only over HTTP/2+HTTPS with `duplex: 'half'`, always CORS-preflighted); Firefox and desktop Safari still buffer the full request body as of current stable channels (WebKit is adding it under Interop 2026, landed in a Safari 26.4 beta, not GA). Fetch response-body streaming (download side) is broadly supported, but doesn't remove the need to buffer before upload on non-Chromium engines. Conclusion: the web buffered fallback is correct for all three engines today, not an XHR-only workaround to revisit later.

## Open questions
None outstanding — resolved during design (see risks above for accepted tradeoffs).

## Sources
- [Streaming requests with the fetch API — Chrome for Developers](https://developer.chrome.com/docs/capabilities/web-apis/fetch-streaming-requests)
- [Request: duplex property — MDN](https://developer.mozilla.org/en-US/docs/Web/API/Request/duplex)
- [Fetch streaming upload · Issue #24 · WebKit/standards-positions](https://github.com/WebKit/standards-positions/issues/24)
- [Announcing Interop 2026 — WebKit](https://webkit.org/blog/17818/announcing-interop-2026/)
- [WebKit Features for Safari 26.4 — WebKit](https://webkit.org/blog/17862/webkit-features-for-safari-26-4/)
- [ResponseType.stream returns response all at once on Web · Issue #2268 · cfug/dio](https://github.com/cfug/dio/issues/2268)
- [Fetch upload streams — caniuse](https://caniuse.com/wf-fetch-request-streams)
