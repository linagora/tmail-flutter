# 0106. Keep attachment uploads on the root isolate

Date: 2026-08-27

## Status

Accepted

## Context

Mobile attachment uploads ran in a worker isolate with a separate `DioClient`, OIDC interceptor, and Hive access. Concurrent upload 401 responses could invoke native AppAuth in parallel and corrupt persistence used by the next app launch.

## Decision

- `FileUploader` uses the root `DioClient`; attachment uploads do not initialize Hive or native authentication from a worker isolate.
- Each file still streams on its own asynchronous socket and progress stream.
- A 401 retry rebuilds its consumed body from a file path or retained bytes.
- On mobile the retry replays the original `RequestOptions` via `Dio.fetch`, so `onSendProgress`, `CancelToken`, timeouts and response type survive the refresh. Web keeps the legacy `Dio.request` path because it is already correct there and this fix must not change its execution path.
- Merging the previously separate web and isolate code paths cost web its structural guarantee of never touching `dart:io`, so `FileUploader` treats an attachment as byte-backed whenever it runs on web.
- Charset detection reads at most 256 KiB, because it only needs a prefix and the root isolate must not materialise a whole text attachment.
- An attachment with neither a file path nor bytes raises `MissingAttachmentSourceException` rather than silently uploading an empty body.
- Charset detection runs after the server stored the blob, so a probe failure degrades to an unknown charset instead of discarding a completed upload.

## Consequences

- Upload 401 responses share the root authorization owner, so AppAuth refreshes cannot race between attachment workers.
- Batch uploads remain concurrent and do not block attachment chips or the UI.
- Upload progress keeps reporting across a token refresh on mobile, which the previous retry dropped.
- The upload path no longer opens Hive from a worker isolate.
- `NetworkBindings` owns `FileUploader` and `HtmlAnalyzer`; `NetworkIsolateBindings` no longer registers upload dependencies.
- `CancelToken` now reaches Dio on mobile, so cancelling aborts the request instead of letting it upload the whole file and only marking the UI as cancelled.
- Physical iOS validation remains required.
