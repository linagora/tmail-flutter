# 105. Attach Drive File via JMAP-mediated Upload

Date: 2026-08-17

## Status

Proposed

## Reference

- Supersedes [ADR-0103](0103-attach-drive-file-as-attachment.md) (Rejected).
- Builds on [ADR-0095](0095-external-drive-file-picker-integration.md), which is unchanged.

## Context

- ADR-0103 had the client stream a drive document's `downloadLink` and upload the bytes itself.
- That's reversed: the JMAP server now does the download-from-drive and the upload itself.
- The client only decides eligibility, then hands off one JMAP call per document.
- That call carries name/mimeType/downloadLink — not bytes.
- Backend has specified the method: tmail-backend#2556 (see Sources).
- Not shipped yet — gated behind `upload.from.url.enabled`, default `false`.
- Interim: until it ships, a downloadable document keeps today's in-development toast.

## Decision

- **Partitioning is unchanged.** A sharing link routes to an HTML link, everything else downloads.
- **Validation is unchanged.** The non-link batch still goes through ADR-0103's validator kernel.
- The JMAP server is the actual enforcement boundary, not the client.
- SSRF checks and byte-size enforcement both happen server-side now.
- **The JMAP contract (issue #2556):** a session capability gates whether the client offers it.
- One synchronous call per document, carrying the `downloadLink` — not a batch endpoint.
- The response is the standard JMAP upload shape, or a typed error — no polling.
- A multi-document pick fans out with bounded client-side concurrency.
- **The gateway lives in the main app, not `workplace`.**
- `workplace` can't reach the JMAP session/repository layer this call needs.
- **Chip UX collapses to one indeterminate state.**
- The client no longer observes separate download/upload legs, so there's no progress percentage.
- **Module boundary.** `workplace` keeps the intent protocol and the link/non-link partition.
- The JMAP call and chip state live in the main app — same split ADR-0103 drew, smaller now.

## Consequences

- ADR-0103's client-side transfer mechanism is void — the server does the fetch and upload now.
- Part of that mechanism is already merged into `master`; removing it is a forward step.
- Everything above the transfer boundary survives: partition logic, validator, chip model.
- Client-side memory-flatness, OPFS quota, and mid-upload-401 concerns disappear for this path.

## Sources

- [ADR-0095: External drive file picker integration](0095-external-drive-file-picker-integration.md)
- [ADR-0103: Attach Drive File as Attachment (Rejected)](0103-attach-drive-file-as-attachment.md)
- [tmail-backend#2556](https://github.com/linagora/tmail-backend/issues/2556): upload-from-URL spec
