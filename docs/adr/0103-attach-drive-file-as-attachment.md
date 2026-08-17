# 103. Attach Drive File as Attachment

Date: 2026-07-07

## Status

Rejected — superseded by [ADR-0105](0105-attach-drive-file-via-jmap-mediated-upload.md). The
backend now owns the drive-to-attachment transfer; the client no longer downloads or uploads
bytes for this path, which voids this ADR's staging/upload architecture.

## Reference
Builds on [ADR-0095](0095-external-drive-file-picker-integration.md) (intent protocol, `DriveDocument` entity, link-only insertion).

## Context

Composer already inserts picked drive documents that carry a `sharingLink` as HTML links. Documents that instead carry a `downloadLink` must be downloaded and attached as real email attachments. The `downloadLink` is a public, short-lived URL (~5–10 minute TTL, no JMAP authentication). Files can be large, and the client runs on memory-constrained mobile devices as well as web, so the download-and-attach path keeps memory flat wherever the platform allows it (IO always; web whenever OPFS is available — see the buffered fallback below).

## Decision

**Partitioning:** `DriveAttachmentHandler` splits picked `DriveDocument`s per-doc: `sharingLink != null` → HTML link (unchanged); `sharingLink == null && downloadLink != null` → download + attach (new). When a doc carries both fields, `sharingLink` wins — a live, editable link gives the recipient more value than a static copy. The two sets are exclusive by construction, decided in the partition step, not by call-site order.

**Stage then upload, platform-appropriate staging:** each downloadable doc is streamed into platform-appropriate temporary storage, then uploaded from that storage. A `DriveFileStager` interface has one implementation per platform capability, selected once per batch via `DriveTransferStrategyFactory.create()` (conditional export: `_mobile.dart` / `if (dart.library.html) _web.dart`, matching `workplace/lib/presentation/view/drive_intent_web_view_modal.dart`).

- **IO (mobile/desktop):** stream the public `downloadLink` with `WorkplaceDio.instance.get(responseType: ResponseType.stream, receiveTimeout: const Duration(seconds: 60))` — raised from `WorkplaceDio`'s 10s default to tolerate slow export-on-demand backends (e.g. Cozy) that can be slow to first byte, while still tripping on a stalled mid-transfer connection — and write each chunk to a temp file in `getTemporaryDirectory()` (`RandomAccessFile.writeFrom`, pause/resume, cancel-aware — the file-write technique proven in `DownloadManager.downloadFile`). `WorkplaceDio.instance` (`workplace/lib/data/workplace_dio.dart`) is a `Dio()` with only timeout `BaseOptions` (10s send/receive/connect) and no interceptors, so the public `downloadLink` is never routed through the main app's `AuthorizationInterceptors` — that interceptor attaches a Bearer/Basic header to every request on the shared `DioClient` instance regardless of host, and `DownloadManager.downloadFile`'s use of that shared client is safe only because its target is the same trusted JMAP host, unlike the external Drive host here; using the shared client for the Drive download would leak the session token to that external host. The upload builds `FileInfo(filePath: tempPath, ...)` and goes through the existing upload path: the worker isolate reads the file lazily via `File(filePath).openRead()`, keeping memory flat and CPU work off the main thread.
- **Web + OPFS** (feature-detected: `navigator.storage.getDirectory` and `FileSystemFileHandle.createWritable` both present — Baseline across Chrome/Edge, Firefox, and Safari as of Safari 26.0/Sept 2025): the download streams via `fetch()` + `ReadableStream`, written incrementally to a temp file in the Origin Private File System; the upload sends that file directly via a raw `XMLHttpRequest` (`xhr.send(file)`) — the browser streams the OPFS-backed file to the network without materializing it in the JS heap.
- **Web buffered** (OPFS unavailable): `Dio.get(responseType: ResponseType.bytes)` into `FileInfo.bytes`, uploaded through the existing bytes-body path — the explicit, feature-detected fallback for browsers without OPFS write support. The actual-byte guard (below) still tracks this leg via `onReceiveProgress` and cancels the request on breach, but `ResponseType.bytes` assembles the full response before the stager receives it, so this path is checked, not memory-flat.

A stager yields a sealed result — `FileBackedStagedFile` (IO temp file), `OpfsStagedFile` (OPFS handle), or `BytesStagedFile` (buffered bytes) — so the upload step's `switch` on it is exhaustive and a missing case is a compile error. `FileBackedStagedFile` and `BytesStagedFile` upload through the shared `FileUploader`; `OpfsStagedFile` uploads via a web-only raw-XHR uploader. Every staged file's `dispose()` runs in a `finally`, removing the temp file (disk or OPFS) on every exit path (success, error, cancel).

**Bounded, per-file pipeline:** a worker pool runs per-file pipelines (download → upload) with no "download all, then upload all" batching — each file's upload starts the instant its own download resolves, and a new download starts as a slot frees. A failing file logs and removes its chip; others continue.

**Upload pipeline:** IO and web-buffered drive attachments reuse `FileUploader`. IO uploads a temp `filePath`, so the pre-existing worker-isolate path is preserved (Dio drives the socket off the Dart main thread; `text/plain` charset detection stays on the worker isolate). `FileUploader`'s main-isolate branch (used on web and single-core devices) is extended to accept `filePath`, not only `bytes`, so single-core devices stream from disk too — this includes setting `filePathExtraKey` in its `mapExtra` (today that branch sets only `streamDataExtraKey`, `file_uploader.dart:175-180`), without which single-core IO uploads are not 401-retry-safe. Local-file/paste/drop uploads are unaffected. The web+OPFS uploader bypasses `FileUploader` — a raw XHR call driving the composer chip's progress state directly.

**401-retry:** IO uploads are `filePath`-backed, so a 401 mid-upload is retried safely — `AuthorizationInterceptors` rebuilds the body by reopening the file from disk, keyed off `filePathExtraKey` (`authorization_interceptors.dart:432-434`). This holds on both the worker-isolate branch (already sets `filePathExtraKey`) and the extended main-isolate branch (per above). No interceptor changes. The web+OPFS raw-XHR upload reads a fresh token once per request and is not refresh-and-retry safe; on any error the file's chip fails and is removed (partial success), the same path as any other transfer failure.

**Visible progress / cancel:** `UploadFileStatus` gains `downloading` (color-distinct from `uploading`); the composer progress widget gains a render branch for it. Each drive file gets a chip immediately in `downloading` state, fed by the stager's `onDownloadProgress`, then flips to `uploading`, showing two genuine sequential phases on every platform. A single `CancelToken` per file spans both stages, so cancelling (including deleting the chip mid-transfer) aborts whichever stage is active.

**End-to-end flow for `DriveAttachmentHandler`:** partition (sharingLink vs downloadLink) → validate total size of the downloadable set *before any download starts* (declared-size gate, below) → bounded-concurrency per-file pipeline (stage → upload) → chip updated to terminal state.

**Validation — pure rules, dialogs only at the edge:** every "may the user attach this?" question runs through one small kernel (`domain/validator/`). A rule sees a request and gives one of three answers:

```dart
sealed class ValidationDecision<Failure, Prompt> {}
final class ValidationAllowed<…> extends ValidationDecision<…> {}
final class ValidationRejected<…> extends ValidationDecision<…> { final Failure failure; }
final class ValidationConfirmationRequired<…> extends ValidationDecision<…> { final List<Prompt> prompts; }

abstract interface class ValidationRule<Request, Failure, Prompt> {
  ValidationDecision<Failure, Prompt> validate(Request request);
}
```

`ValidationPipeline` runs its rules in order: the first rejection wins and stops everything, otherwise all collected prompts are asked together. Rules are pure and synchronous — no `BuildContext`, no localization, no dialogs — so they unit-test with a plain `test()`. The kernel is generic over `Request`/`Failure`/`Prompt`; attachments are one instantiation of it, and today there is exactly one rule, `AttachmentSizeLimitRule`.

**Two totals, two limits.** A request carries byte totals split two ways, because the thresholds don't measure the same thing:

| Total | Includes inline images? | Limit |
|---|---|---|
| all attachments | yes | server `maxSizeAttachmentsPerEmail` → hard reject |
| regular attachments | no | `AppConfig` warning threshold → ask before continuing |

So pasting an inline image never raises the "large attachment" warning, but can still hit the server cap. `AttachmentUploadRequestFactory` does the split from `FileInfo.isInline`, or straight from byte counts when a call site has no `FileInfo` (re-attaching an already-uploaded attachment).

**The gate is where a decision becomes UI** — one type, every call site goes through it:

```dart
switch (_validator.validate(request)) {
  case ValidationAllowed(): return true;
  case ValidationRejected(:final failure): await feedback.showFailure(failure); return false;
  case ValidationConfirmationRequired(:final prompts): return feedback.confirmAll(prompts);
}
```

**Numbers.** `ComposerAttachmentUploadStateSource` adapts `UploadController` totals + limits to the `AttachmentUploadStateSource` port — all getters, so the server cap is re-read per check. Totals prefer `attachment.size`, so forwarded and draft attachments count. Intended.

**Declared vs. actual size:** the pre-download gate sums `DriveDocument.size` — backend-reported metadata, unreliable for export-on-demand documents (e.g. Cozy, which may report `0` up front). A running actual-byte guard runs alongside the declared-size gate: a shared counter updated with each file's progress *delta* — `onDownloadProgress`/`onReceiveProgress` reports bytes received *cumulatively per file*, so each stager tracks its own previous callback value and adds only the difference to the shared counter (summing raw cumulative values would double-count and cancel valid downloads early). The shared counter is checked against budget on every update and cancels that file's transfer once exceeded, caught as a per-file failure. The declared-size gate still fails fast before wasting a download; the hard cap comes from the server `maxSizeAttachmentsPerEmail` capability. When that capability is absent, the guard's budget falls back to a fixed client-side constant — this fallback is local to the actual-byte guard; the size-limit dialog check (`AttachmentSizeLimitPolicy`, driven by `AttachmentSizeLimitRule`) is unchanged and keeps treating an absent capability as unlimited for every attachment source, not only drive.

The counter's check-then-increment runs synchronously inside each `onDownloadProgress` callback with no `await` in between, so on Dart's single-threaded event loop it cannot interleave across concurrent files — the only possible overshoot is one in-flight progress-chunk per file at the moment the guard fires, not an unbounded race. No chunk-reservation mechanism is needed.

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
- Stream receive-timeout on the Dio-backed download legs (IO, web-buffered) is a finite 60s, up from `WorkplaceDio`'s 10s default, to tolerate slow-to-first-byte export-on-demand backends (e.g. Cozy). `receiveTimeout`, when set, guards both time-to-first-byte/headers *and* the gap between subsequent byte events (verified against Dio 5.2.0 and current 5.9.0 source) — it is not a to-first-byte-only timeout — so a healthy streaming download that emits bytes continuously never trips it, while a stalled mid-transfer connection is caught automatically instead of relying solely on manual cancel.
- Concurrency adapts by CPU count/platform but is not user-configurable.
- Browsers without OPFS `createWritable()` transparently fall back to the buffered strategy — no user-facing error, but no memory-flat guarantee there.

## Open questions
None outstanding.

## Sources
- [FileSystemFileHandle: createWritable() method — MDN](https://developer.mozilla.org/en-US/docs/Web/API/FileSystemFileHandle/createWritable)
- [Origin private file system — MDN](https://developer.mozilla.org/en-US/docs/Web/API/File_System_API/Origin_private_file_system)
- [WebKit Features in Safari 26.0 — WebKit](https://webkit.org/blog/17333/webkit-features-in-safari-26-0/)
- [ResponseType.stream returns response all at once on Web · Issue #2268 · cfug/dio](https://github.com/cfug/dio/issues/2268)
