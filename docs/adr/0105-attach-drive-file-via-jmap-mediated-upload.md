# 105. Attach Drive File via JMAP-mediated Upload

Date: 2026-08-17

## Status

Proposed

## Reference

Supersedes [ADR-0103](0103-attach-drive-file-as-attachment.md) (Rejected). Builds on
[ADR-0095](0095-external-drive-file-picker-integration.md) (intent protocol, `DriveDocument`
entity, link-only insertion), which is unchanged.

## Context

ADR-0103 had the client stream a drive document's `downloadLink` itself and upload the bytes
through the existing JMAP-upload path, memory-flat wherever the platform allowed it. That decision
is reversed: the JMAP server does the download-from-drive and upload itself. The client's role for
a downloadable document shrinks to two steps it already does for every other attachment path —
decide whether the document is eligible, then hand off — followed by one JMAP call per document
carrying the info the drive picker returned (name, mimeType, downloadLink), instead of the bytes
themselves.

Backend has now specified the method:
[linagora/tmail-backend#2556](https://github.com/linagora/tmail-backend/issues/2556). It is not
shipped yet — gated behind `upload.from.url.enabled`, default `false` — but its shape is fixed, so
this ADR records the full design instead of stopping at the architectural shift.

## Decision

**Partitioning is unchanged.** `doc.sharingLink != null` → HTML link; everything else with a
downloadable link → the non-link path. Decided once, in one place, as today.

**Validation is unchanged.** The document still goes through the same validator kernel ADR-0103
introduced (`lib/features/upload/domain/validator/`): pure rules, a pipeline that short-circuits
on rejection and otherwise collects confirmation prompts, and the two-totals/two-limits size gate
(`AttachmentSizeLimitRule`, summing `DriveDocument.size` across the batch). None of that logic
assumed a client-side download — it only ever gated "may this many declared bytes be attached."
This declared-size check is early UX only: `DriveDocument.size` is metadata the drive backend
reported, not a measured byte count, and the JMAP server is the actual enforcement boundary (see
below). The one thing that changes is what runs once validation allows the batch: a JMAP call per
document instead of a download.

**The JMAP contract, per issue #2556:**
- Capability `com:linagora:params:jmap:upload:from-url` advertises
  `uploadUrl: https://mail.example.com/upload-from-url/{accountId}` in the JMAP session object.
  The client only offers this path when its session exposes the capability — until backend enables
  `upload.from.url.enabled`, the capability is absent and the interim behavior below applies.
- One call per document: `POST /upload-from-url/{accountId}` with `Content-Location: <downloadLink>`
  and an optional `Content-Type`. Not a batch endpoint — a multi-document non-link selection issues
  one request per document, run with bounded client-side concurrency (see Gateway below).
- Synchronous: the response is the standard JMAP upload shape (`201 Created`, `accountId`,
  `blobId`, `type`, `size`), or a typed error (`400`/`401`/`403`/`413`/`429`/`502`/`504`/`500`).
  The chip resolves directly off this response — no polling or push completion to design around.
- The server does the fetch, the SSRF/allowlist validation, and enforces `upload.max.size` against
  the **decoded** bytes it actually reads, not the client-declared size. This is the client's
  answer to both the SSRF and the actual-byte-enforcement concern: neither needs a client-side
  change, because the server is already the trust and enforcement boundary for this call.
- The fetch happens synchronously inside request handling — the client calls upload-from-url right
  after the drive pick, so the `downloadLink`'s short TTL is never in play; there is no deferred or
  queued fetch on the client side that could outlive it.

**Gateway/usecase, main app only.** `workplace` cannot depend on the JMAP session/repository layer
the call needs, so the port lives in the main app, following the existing `domain/usecases` +
repository pattern used elsewhere in `lib/features/upload/`. Signature: one usecase call per
document, `(accountId, downloadLink, name, mimeType) → Either<Failure, Attachment>`, the
`Attachment` built from the response's `blobId`/`type`/`size`. A multi-document pick fans out
through `runWithConcurrency` (`lib/features/composer/presentation/manager/
bounded_concurrency_runner.dart`, cherry-picked from the abandoned branch — see Consequences),
bounding how many `upload-from-url` calls run at once.

**Validator entry point.** `AttachmentUploadValidationService` gains `validateBytes` (already
prototyped on the abandoned branch, reused here) summing `DriveDocument.size` across the
non-link batch via the existing `fromProposedBytes` request factory. Its `onAllowed` becomes
async-capable (`Future<void> Function()` instead of `VoidCallback`), since it now needs to await
the per-document gateway calls before the chips can settle. `validateFiles`/`validateAttachment`
keep their existing synchronous signature — only the drive path needs to await.

**Chip UX collapses to one indeterminate state.** ADR-0103's two-phase `downloading`/`uploading`
progress existed because the client was moving bytes through two distinct legs it could observe.
Under this decision the client observes nothing between issuing the call and getting the response,
so the chip design collapses to a single `attaching` status with no progress percentage: a
placeholder is added for every picked document up front (so the on-screen count matches the
selection immediately), then each resolves to attached (with the `Attachment` the response
carries) or failed — the same terminal shape every other attachment source already has.

**Module boundary.** `workplace` keeps the intent protocol, `DriveDocument`, and link-only
insertion (ADR-0095), and stays the source of the partition (`DriveDocumentExtension`,
cherry-picked from the abandoned branch). The validation call, the new gateway, and the chip state
live in the main app — the same boundary ADR-0103 drew, just with a much smaller main-app side.

**Interim behavior.** Until backend ships and enables the capability, a downloadable document
keeps today's `driveAttachmentInDevelopment` toast (the current `master` behavior).

## Consequences

- The client-side transfer *mechanism* from ADR-0103 — the stagers, sealed staged-file types, the
  IO/OPFS/buffered strategies, the actual-byte guard, OPFS storage-lifecycle/quota handling, and
  upload-phase token refresh — is void; the server does the fetch and upload now. Concretely:
  `workplace/lib/data/datasource/drive_transfer/**` and its tests are void — and unlike the rest of
  ADR-0103's build-out, this one is **already merged into master** via TF-4727 (#4729/#4731/#4746),
  not just parked on the abandoned branch. Its removal is an owned step in the forward plan, not an
  automatic consequence of the branch being abandoned.
- What survives from the abandoned `feature/TF-4728-1-attach-drive-file-on-web` branch is
  everything *above* the transfer boundary: the partition extension, the validator's
  `validateBytes` entry point, the `DriveAttachmentHandler` restructure (dispatching both halves of
  a mixed pick), the bounded-concurrency runner, the placeholder-chip model, and the success toast
  string. Only the transfer leg itself — `DriveTransferPipeline`, `DriveDocumentTransferRunner`,
  the OPFS strategies, and the upload-phase `AuthorizationInterceptors` token-refresh — is replaced
  by the JMAP gateway call.
- Client-side memory-flatness, disk/OPFS quota, and mid-upload-401 concerns disappear for this
  path — the client never holds attachment bytes.
- The validator kernel from ADR-0103 is retained as-is and now gates a batch of JMAP calls instead
  of a batch of downloads.

## Risks

- Chip UX is coarser than ADR-0103's: one indeterminate state instead of a two-phase progress bar,
  unless the server later exposes transfer progress through another channel.

## Open questions

- Error-to-chip mapping: which of the `400`/`401`/`403`/`413`/`429`/`502`/`504`/`500` responses are
  worth surfacing as distinct user-facing messages versus a generic "attach failed," and whether
  any (e.g. `429`) should offer a retry instead of a terminal failure.
- Whether the client checks capability presence once per JMAP session or on every attach attempt —
  a minor perf/UX call, not an architectural one.

## Sources

- [ADR-0095: External drive file picker integration](0095-external-drive-file-picker-integration.md)
- [ADR-0103: Attach Drive File as Attachment (Rejected)](0103-attach-drive-file-as-attachment.md)
- [tmail-backend#2556: JMAP upload from URL for Twake Drive attachments](https://github.com/linagora/tmail-backend/issues/2556)
