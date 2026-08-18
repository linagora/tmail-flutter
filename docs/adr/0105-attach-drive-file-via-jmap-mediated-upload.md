# 105. Attach Drive File via JMAP-mediated Upload

Date: 2026-08-17

## Status

Proposed

## Reference

- Supersedes [ADR-0103](0103-attach-drive-file-as-attachment.md) (Rejected).
- Builds on [ADR-0095](0095-external-drive-file-picker-integration.md), which is unchanged.

## Context

- ADR-0103 had the client stream and re-upload a drive document's bytes itself.
- That's reversed: the JMAP server now fetches from Drive and uploads it itself.
- The client only decides eligibility, then hands off one JMAP call per document.
- Backend has specified the method: tmail-backend#2556, gated behind `upload.from.url.enabled`.

## Decision

- **Partitioning is unchanged.** `sharingLink != null → HTML link; else → JMAP call`.
- **No client-side validation for drive picks.** Twake Drive enforces `maxFileSize` per file.
- A future drive-side total-batch-size config can be added when Drive supports it.
- Every non-link pick goes straight to the JMAP call — no rejection UI, no re-pick loop.
- The JMAP server is still the enforcement boundary for the bytes it actually fetches.
- **Picker init is capability-gated.** No capability ⇒ no download/attach action offered.
- **The JMAP contract (issue #2556):** a session capability gates whether the client offers it.
- One synchronous call per document, carrying the `downloadLink` — not a batch endpoint.
- The response is the standard JMAP upload shape, or a typed error — no polling.
- Call goes through the authenticated JMAP Dio client, never `WorkplaceDio`.
- A multi-document pick fans out with bounded client-side concurrency.
- **The gateway lives in the main app, not `workplace`.**
- `workplace` can't reach the JMAP session/repository layer this call needs.
- **Chip UX reuses the existing indeterminate `waiting` status** — no new status added.
- Each call is individually cancellable, tied to that chip's delete/dispose.
- No short receive-timeout override on this call.
- Errors are handled the same way the existing file uploader already handles them.
- `downloadLink` is never logged (Dio, Sentry, or `Failure` payloads).
- **Module boundary.** `workplace` keeps the intent protocol and the link/non-link partition.
- The JMAP call and chip state live in the main app — same split ADR-0103 drew, smaller now.

## Consequences

- ADR-0103's client-side transfer mechanism is void — the server does the fetch and upload now.
- Part of that mechanism is already merged into `master`; removing it is a forward step.
- Everything above the transfer boundary survives: partition logic, chip placeholder model.
- Client-side memory-flatness, OPFS quota, and mid-upload-401 concerns disappear for this path.
- Chip UX is coarser than ADR-0103's two-phase progress bar, since there's only one leg to watch.
- That stays true unless the server later exposes transfer progress through another channel.

## Open questions

- The concurrency bound value for fan-out (decided during implementation).
- When Drive ships a total-batch-size config, whether/how the client should surface it.

## Sources

- [ADR-0095: External drive file picker integration](0095-external-drive-file-picker-integration.md)
- [ADR-0103: Attach Drive File as Attachment (Rejected)](0103-attach-drive-file-as-attachment.md)
- [tmail-backend#2556](https://github.com/linagora/tmail-backend/issues/2556): upload-from-URL spec
