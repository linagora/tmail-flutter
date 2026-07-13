# 103. Attach Drive File as Attachment

Date: 2026-07-07

## Status

Proposed

## Reference
Builds on [ADR-0095](0095-external-drive-file-picker-integration.md) (intent protocol, `DriveDocument` entity, link-only insertion).

## Context

Composer already inserts picked drive documents that carry a `sharingLink` as HTML links. Documents that instead carry a `downloadLink` must be downloaded and attached as real email attachments. The `downloadLink` is a public, short-lived URL (~5–10 minute TTL, no JMAP authentication). Files can be large, and the client runs on memory-constrained mobile devices as well as web, so the download-and-attach path keeps memory flat on every platform.

## Decision

**Partitioning:** `DriveAttachmentHandler` splits picked `DriveDocument`s per-doc: `sharingLink != null` → HTML link (unchanged); `sharingLink == null && downloadLink != null` → download + attach (new). When a doc carries both fields, `sharingLink` wins — a live, editable link gives the recipient more value than a static copy. The two sets are exclusive by construction, decided in the partition step, not by call-site order.

**Stage then upload, memory-flat on every platform:** each downloadable doc is streamed into platform-appropriate temporary storage, then uploaded from that storage. A `DriveFileStager` interface has one implementation per platform capability, selected once per batch via `DriveTransferStrategyFactory.create()` (conditional export: `_mobile.dart` / `if (dart.library.html) _web.dart`, matching `workplace/lib/presentation/view/drive_intent_web_view_modal.dart`).

- **IO (mobile/desktop):** stream the public `downloadLink` with `Dio.get(responseType: ResponseType.stream, receiveTimeout: Duration.zero)` (no auth header) and write each chunk to a temp file in `getTemporaryDirectory()` (`RandomAccessFile.writeFrom`, pause/resume, cancel-aware — the technique proven in `DownloadManager.downloadFile`). The upload builds `FileInfo(filePath: tempPath, ...)` and goes through the existing upload path: the worker isolate reads the file lazily via `File(filePath).openRead()`, keeping memory flat and CPU work off the main thread.
- **Web + OPFS** (feature-detected: `navigator.storage.getDirectory` and `FileSystemFileHandle.createWritable` both present — Baseline across Chrome/Edge, Firefox, and Safari as of Safari 26.0/Sept 2025): the download streams via `fetch()` + `ReadableStream`, written incrementally to a temp file in the Origin Private File System; the upload sends that file directly via a raw `XMLHttpRequest` (`xhr.send(file)`) — the browser streams the OPFS-backed file to the network without materializing it in the JS heap.
- **Web buffered** (OPFS unavailable): `Dio.get(responseType: ResponseType.bytes)` into `FileInfo.bytes`, uploaded through the existing bytes-body path — the explicit, feature-detected fallback for browsers without OPFS write support.

A stager yields a sealed result — `FileBackedStagedFile` (IO temp file), `OpfsStagedFile` (OPFS handle), or `BytesStagedFile` (buffered bytes) — so the upload step's `switch` on it is exhaustive and a missing case is a compile error. `FileBackedStagedFile` and `BytesStagedFile` upload through the shared `FileUploader`; `OpfsStagedFile` uploads via a web-only raw-XHR uploader. Every staged file's `dispose()` runs in a `finally`, removing the temp file (disk or OPFS) on every exit path (success, error, cancel).

**Bounded, per-file pipeline:** a worker pool runs per-file pipelines (download → upload) with no "download all, then upload all" batching — each file's upload starts the instant its own download resolves, and a new download starts as a slot frees. A failing file logs and removes its chip; others continue.

**Upload pipeline:** IO and web-buffered drive attachments reuse `FileUploader`. IO uploads a temp `filePath`, so the pre-existing worker-isolate path is preserved (Dio drives the socket off the Dart main thread; `text/plain` charset detection stays on the worker isolate). `FileUploader`'s main-isolate branch (used on web and single-core devices) is extended to accept `filePath`, not only `bytes`, so single-core devices stream from disk too. Local-file/paste/drop uploads are unaffected. The web+OPFS uploader bypasses `FileUploader` — a raw XHR call driving the composer chip's progress state directly.

**401-retry:** IO uploads are `filePath`-backed, so a 401 mid-upload is retried safely — `AuthorizationInterceptors` rebuilds the body by reopening the file from disk. No interceptor changes. The web+OPFS raw-XHR upload reads a fresh token once per request and is not refresh-and-retry safe; on any error the file's chip fails and is removed (partial success), the same path as any other transfer failure.

**Visible progress / cancel:** `UploadFileStatus` gains `downloading` (color-distinct from `uploading`); the composer progress widget gains a render branch for it. Each drive file gets a chip immediately in `downloading` state, fed by the stager's `onDownloadProgress`, then flips to `uploading`, showing two genuine sequential phases on every platform. A single `CancelToken` per file spans both stages, so cancelling (including deleting the chip mid-transfer) aborts whichever stage is active.

**End-to-end flow for `DriveAttachmentHandler`:** partition (sharingLink vs downloadLink) → validate total size of the downloadable set *before any download starts* (declared-size gate, below) → bounded-concurrency per-file pipeline (stage → upload) → chip updated to terminal state.

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
No size (or other condition-specific data) in the interface. Each concrete validator captures what it needs via its own constructor and is self-contained, including showing its own dialog. Today's only concrete validator, `SizeLimitAttachmentUploadValidator`, wraps the existing size-limit/warning-dialog check (`UploadController.validateTotalSizeAttachmentsBeforeUpload`, whose body moves into it with `UploadController` keeping a thin wrapper). Every attachment entry point (composer local-file/paste/drop, `DriveAttachmentHandler`) constructs the validators it needs and calls `.validate()`. A new, unrelated condition later = one new class + one line in a `CompositeAttachmentUploadValidator([...])` list.

**Declared vs. actual size:** the pre-download gate sums `DriveDocument.size` — backend-reported metadata, unreliable for export-on-demand documents (e.g. Cozy, which may report `0` up front). A running actual-byte guard runs alongside the declared-size gate: each stager's download loop checks cumulative bytes across the batch against budget and aborts mid-transfer once exceeded, caught as a per-file failure. The declared-size gate still fails fast before wasting a download; the hard cap comes from the server `maxSizeAttachmentsPerEmail` capability and may be absent, so the actual-byte guard is the reliable bound.

**Hardware-aware concurrency:** the pool size adapts to the device using `Platform.numberOfProcessors` (the signal the app already uses for isolate decisions): IO uses 2 when `numberOfProcessors <= 2`, else 3; web+OPFS uses 3 (flat memory); web-buffered uses 1–2 (each concurrent transfer holds a full `Uint8List`). Not user-configurable.

**Download-link TTL:** the `downloadLink` expires in ~5–10 minutes. Under bounded concurrency a later file in a large batch can find its link expired before its turn; that download fails as a normal per-file failure (chip dropped, others continue). Staging keeps the download connection short-lived — it closes as soon as the file is on disk, before upload — minimizing exposure to drive-side idle timeouts.

**Storage limits:** a full disk (IO `ENOSPC`) or exhausted OPFS quota (`QuotaExceededError`) fails that file per-file and cleans up its temp file.

**Module boundary:** intent protocol, `DriveDocument`, the `DriveFileStager` implementations, the sealed staged-file type, and the web-only OPFS uploader stay in `workplace`; the main app's `DriveAttachmentHandler` composes `DriveTransferStrategyFactory.create()` with the shared validator abstraction and the bounded-concurrency pool, and uploads `FileBackedStagedFile`/`BytesStagedFile` through `FileUploader` (injecting the JMAP upload URI and, for OPFS, the bearer token).

## Consequences
- Drive attachments reuse the same size-limit UX and, on IO/web-buffered, the same `FileUploader` path as every other attachment source. `FileInfo` is unchanged. `FileUploader` gets one additive change — its main-isolate branch accepts `filePath` (not only `bytes`), which also benefits single-core devices. No `AuthorizationInterceptors` change.
- Memory stays flat on IO always, and on web whenever OPFS is available; web-buffered is the explicit, feature-detected fallback for browsers without OPFS write support.
- IO uploads keep the worker-isolate CPU offload and are 401-retry-safe with no interceptor change.
- The user sees live per-file progress with two genuine phases (`downloading` then `uploading`) on every platform, instead of a blocking wait.
- A new attachment-eligibility condition is one new class + one line, not a change to every call site.
- Adding or changing a transfer strategy later (e.g. a Worker + `createSyncAccessHandle` variant) is one new stager implementation plus one line in `DriveTransferStrategyFactory` — orchestration never changes.

## Risks
- The `downloadLink` TTL (~5–10 min) can expire for later files in a large batch under bounded concurrency; those fail per-file and the user re-picks.
- The web+OPFS raw-XHR upload is not 401-refresh-retry-safe (a fresh token is read once per request).
- Disk and OPFS storage are subject to space/quota limits; exhaustion fails that file and cleans up.
- Stream receive-timeout is uncapped (`Duration.zero`) on the Dio-backed download legs (IO, web-buffered); a stalled server relies on the user's manual cancel action. `receiveTimeout` only guards time-to-first-byte/headers on IO, not the whole transfer (verified against Dio 5.2.0 and current 5.9.0 source).
- Concurrency adapts by CPU count/platform but is not user-configurable.
- Browsers without OPFS `createWritable()` transparently fall back to the buffered strategy — no user-facing error, but no memory-flat guarantee there.

## Open questions
None outstanding.

## Sources
- [FileSystemFileHandle: createWritable() method — MDN](https://developer.mozilla.org/en-US/docs/Web/API/FileSystemFileHandle/createWritable)
- [Origin private file system — MDN](https://developer.mozilla.org/en-US/docs/Web/API/File_System_API/Origin_private_file_system)
- [WebKit Features in Safari 26.0 — WebKit](https://webkit.org/blog/17333/webkit-features-in-safari-26-0/)
- [ResponseType.stream returns response all at once on Web · Issue #2268 · cfug/dio](https://github.com/cfug/dio/issues/2268)
