# 103. Attach Drive File as Attachment

Date: 2026-07-07

## Status

Proposed

## Reference
Builds on [ADR-0095](0095-external-drive-file-picker-integration.md) (intent protocol, `DriveDocument` entity, link-only insertion).

## Context

Composer already inserts picked drive documents with a `sharingLink` as HTML links. Documents with a `downloadLink` instead need to be downloaded and attached as real email attachments.

## Decision

**Partitioning:** `DriveAttachmentHandler` splits picked `DriveDocument`s per-doc: `sharingLink != null` → HTML link (unchanged); `downloadLink != null` → download + attach (new). **Invariant:** both fields may be present on one doc (per ADR-0095's payload); when they are, `sharingLink` wins — HTML link only, enforced in the partition step, not call-site order. A live, editable link gives the recipient more value than a static attachment copy, and matches existing behavior (only `sharingLink` docs are rendered as links today; `downloadLink` is net-new).

**Download (`workplace` package), streamed:** `DriveFileDatasourceImpl.openFileForUpload(doc)` branches on `kIsWeb`. **IO**: `Dio.get(responseType: stream)` piped directly as the upload request body (`FileInfo.byteStream`) — zero-copy. **Web**: XHR can't stream a body, so web buffers into `FileInfo.bytes`. A bounded worker pool (`kMaxConcurrentDriveTransfers = 3`, new constant, not tied to any existing limit) runs per-file pipelines with no "download all, then upload all" batching. A failing file logs/removes its chip; others continue.

**Upload pipeline contract:** the worker-isolate upload path (`FileUploader.uploadAttachment` → `UploadFileArguments`) only carries `filePath`/`bytes` across the isolate boundary — a one-shot `Stream<List<int>>` can't cross it. So **drive stream uploads run on the main isolate** instead, bypassing the worker-isolate branch. Local-file/paste/drop uploads are unaffected. **Impact:** this is I/O plumbing (Dio drives the socket off the Dart main thread already), not CPU-bound work, so UI jank risk is low — unlike, say, decoding a large payload on the main isolate. The worker-isolate path exists for the CPU-bound charset/multipart prep on `bytes`, which streamed uploads skip entirely.

**Visible progress:** each drive file gets a composer attachment chip immediately (`UploadFileStatus.downloading`, color-distinct from `uploading`), fed by `onDownloadProgress`/Dio's existing `onSendProgress`. IO shows one continuous phase (download+upload coupled by the pipe); web shows two sequential phases (download then upload).

**Progress/cancel model:** `UploadFileStatus` gains `downloading`; `AttachmentUploadState` gains a matching `DownloadingAttachmentUploadState`; the composer progress widget gains a render branch for it. A single `CancelToken` per file spans both the download and upload calls, so cancelling (including deleting the chip mid-transfer) aborts whichever stage is active.

**End-to-end flow for `DriveAttachmentHandler`:** partition (sharingLink vs downloadLink, above) → validate total size of the downloadable set *before any download starts* (declared-size gate, below) → bounded-concurrency per-file pipeline (download → upload) → chip updated to terminal state. Validation runs once, up front, against the whole batch — not per file and not interleaved with downloads.

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

**Validator migration boundary:** `SizeLimitAttachmentUploadValidator` lives in the main app next to `UploadController`, not in `workplace` — it needs `BuildContext`, mailbox max-size config, localization, and dialogs. `UploadController.validateTotalSizeAttachmentsBeforeUpload`'s body moves into it as-is; `UploadController` keeps a thin wrapper so call sites don't change. Local-file, paste, drop, and drive entry points all migrate to it in the same change — not staged as a follow-up. `DriveAttachmentHandler` depends on the `AttachmentUploadValidator` interface, not on `UploadController` directly.

**Declared vs. actual size:** the pre-download total-size gate sums `DriveDocument.size` — backend-reported metadata, not a measured local file. That's untrustworthy for at least one real case: Cozy-style documents whose byte size is only known at export/download time and may report `0` (or a stale value) up front. A doc that clears the pre-check on a lying `size` can still blow the total budget once actually downloaded. Mitigation: an actual-byte guard runs alongside the declared-size gate, not instead of it — declared size still fails fast before wasting a download. Web (already fully buffers before uploading) re-checks `bytes.length` against the batch budget before triggering upload. IO (zero-copy pipe, no discrete "download done" point) wraps the download stream in a byte-counting transformer that aborts the pipe once cumulative actual bytes for the batch exceed budget, mid-stream — same partial-success/cancel path as any other pipe failure.

**Upload (reused as-is):** downloaded/picked `FileInfo`s all go through the composer's existing single upload trigger. Drive attachments are indistinguishable from local ones past this point, except for the main-isolate routing noted above.

**Retry policy for drive-stream uploads:** `AuthorizationInterceptors._retryRequest` retries upload requests by rebuilding the body from `filePath` (reopenable, safe) or the stored stream/bytes object (safe for bytes, not safe for an already-consumed one-shot stream). Drive-stream requests carry a new `nonRetryableUploadBody: true` extra flag; `_retryRequest` checks it first and skips retry when set, failing immediately instead of replaying a consumed stream. Additive — no change to existing filePath/bytes retry behavior. **Alternative considered and rejected:** buffer the download to a temp file first, so the upload body is a reopenable file (retry-safe like `filePath` today). Rejected because it defeats the zero-copy streaming goal that's the point of the IO path — adds disk I/O and temp-file lifecycle/cleanup for potentially large files, to buy back retry-safety on a failure mode that's already rare (401 mid-transfer) and already has an acceptable fallback (fail, drop chip, user retries the whole file).

**Considered, not adopted:** a `DriveFileDownloader` interface with separate mobile/web implementations. The current single method branching on `kIsWeb` is two ~10-line branches behind one signature — an interface + two classes is more ceremony for the same two cases (YAGNI). Revisit if a third platform variant appears. Also considered: writing web downloads to Origin Private File System instead of buffering in memory, to reduce peak web memory for large files. Plausible win, but only if paired with a `fetch()`-based streaming download/upload path — Dio's XHR web adapter already fully materializes the response before handing it back (see `dio` issue #2268 in Sources), so layering OPFS under the existing Dio call buys nothing. A `fetch()` + OPFS path bypasses Dio's web adapter entirely for drive files, which is a bigger lift than today's design for a large-file-only edge case. Tracked as a follow-up spike, not part of this ADR.

**Module boundary:** intent protocol, `DriveDocument`, and the download chain stay in `workplace`; only `DriveAttachmentHandler` (main app) composes download orchestration with the shared validator abstraction and the composer's existing upload trigger.

## Consequences
- Drive attachments reuse the same size-limit UX and upload pipeline as every other attachment source; `FileInfo` gains an additive `byteStream` field. `FileUploader` gains two additive changes: drive-stream uploads route to the main-isolate path (not worker-isolate), and carry `nonRetryableUploadBody: true` so the auth interceptor skips retry. Neither affects local-file/paste/drop uploads.
- A new attachment-eligibility condition is one new class + one line, not a change to every call site.
- Memory stays flat on IO regardless of file size/concurrent count (zero-copy pipe); web still buffers per file (XHR limitation).
- User sees live per-file progress immediately instead of a blocking wait.
- A streamed IO upload isn't 401-retry-safe (one-shot body can't be rebuilt) — accepted and made explicit via `nonRetryableUploadBody`: that file's chip fails and is removed, others continue (see Retry Policy above).
- **Web buffering is a browser platform limit, not a Dio-specific gap — confirmed, not an open risk.** Verified via `dio_web_adapter` 2.1.1 source (current, ships with `dio: 5.9.0`) — still XHR-based, still fully buffers the request stream before `xhr.send()`. A hand-rolled `fetch()` client wouldn't help either: streaming *upload* request bodies only works on Chromium (Chrome/Edge/Opera, v105+, and only over HTTP/2+HTTPS with `duplex: 'half'`, always CORS-preflighted); Firefox and desktop Safari still buffer the full request body as of current stable channels (WebKit is adding it under Interop 2026, landed in a Safari 26.4 beta, not GA). Fetch response-body streaming (download side) is broadly supported, but doesn't remove the need to buffer before upload on non-Chromium engines. Conclusion: the web buffered fallback is correct for all three engines today, not an XHR-only workaround to revisit later (see "Considered, not adopted" above for the OPFS alternative).

## Risks
- IO shows only a single-phase "downloading"-styled bar for the whole transfer (download/upload are coupled in lockstep) — accepted over forcing IO to buffer for a two-phase visual.
- Stream receive-timeout is uncapped (`Duration.zero`); a stalled server relies on the user's manual cancel action. **Correction after checking Dio's actual IO adapter source (pinned `dio: 5.2.0`, and current 5.9.0):** `receiveTimeout` was never a whole-transfer watchdog on IO in the first place — it only guards time-to-first-byte/headers (`request.close()`), so the 10s default wasn't going to "kill a slow transfer mid-stream" either way. Setting `Duration.zero` still avoids a spurious timeout before a slow drive file starts streaming, just not for the reason originally stated.
- Concurrency fixed at 3 concurrent transfers, not user/config-configurable (YAGNI for now).

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
