# 104. Attach Drive File via JMAP-mediated Upload

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
is reversed: the JMAP server will now do the download-from-drive and upload itself. The client's
role for a downloadable document shrinks to two steps it already does for every other attachment
path — decide whether the document is eligible, then hand off — followed by a single JMAP call
carrying the document info the drive picker returned (id, name, size, mimeType, link), instead of
the bytes themselves.

No such JMAP method exists yet. Its name, request/response shape, and whether it completes
synchronously or asynchronously are all undefined and owned by backend. This ADR records the
architectural shift at the level that doesn't depend on that shape; the concrete gateway wiring is
deferred to the forward plan once backend specifies it.

## Decision

**Partitioning is unchanged.** `doc.sharingLink != null` → HTML link; everything else with a
downloadable link → the non-link path. Decided once, in one place, as today.

**Validation is unchanged.** The document still goes through the same validator kernel ADR-0103
introduced (`lib/features/upload/domain/validator/`): pure rules, a pipeline that short-circuits
on rejection and otherwise collects confirmation prompts, and the two-totals/two-limits size gate
(`AttachmentSizeLimitRule` against `AttachmentUploadValidationService.validateBytes`, summing
`DriveDocument.size` across the batch). None of that logic assumed a client-side download — it
only ever gated "may this many declared bytes be attached." The one thing that changes is what
runs on `ValidationAllowed`: a JMAP call instead of a download.

**A new gateway abstraction, not yet filled in.** The main app defines a domain-layer
port/usecase — following the existing `domain/usecases` + repository pattern used elsewhere in
`lib/features/upload/` — that wraps the eventual JMAP call. It lives in the main app, not
`workplace`: `workplace` cannot depend on the JMAP session/repository layer the call needs.
Request and response types are deliberately left undefined here; they're fixed once backend
specifies the method, at which point implementing this port is a small, isolated change.

**Chip UX collapses to one indeterminate state.** ADR-0103's two-phase `downloading`/`uploading`
progress existed because the client was moving bytes through two distinct legs it could observe.
Under this decision the client observes nothing — it issues one call and waits for a result — so
the chip design collapses to a single "attaching" state with no progress percentage, resolving to
attached (with the `Attachment` the JMAP response carries) or failed, the same terminal shape every
other attachment source already has.

**Module boundary.** `workplace` keeps the intent protocol, `DriveDocument`, and link-only
insertion (ADR-0095), and stays the source of the partition. The validation call, the new gateway,
and the chip state live in the main app — the same boundary ADR-0103 drew, just with a much
smaller main-app side.

**Interim behavior.** Until the method exists, a downloadable document keeps today's
`driveAttachmentInDevelopment` toast (the current `master` behavior) — no client change needed
until the gateway can actually be implemented.

## Consequences

- All of ADR-0103's client-side transfer architecture — stagers, sealed staged-file types, the
  IO/OPFS/buffered strategies, the actual-byte guard, OPFS storage-lifecycle/quota handling, and
  upload-phase token refresh — is void. None of it ships.
- Client-side memory-flatness, disk/OPFS quota, and mid-upload-401 concerns disappear for this
  path — the client never holds attachment bytes.
- The validator kernel from ADR-0103 is retained as-is and now gates a JMAP call instead of a
  download.
- The concrete gateway signature, batching (per-document vs batch call), and completion model
  (synchronous response vs asynchronous await) can't be finalized until backend defines the JMAP
  method — that's the next planning trigger, not part of this decision.

## Risks

- Chip UX is coarser than ADR-0103's: one indeterminate state instead of a two-phase progress bar,
  unless the server later exposes transfer progress through another channel.

## Open questions

Client-facing, both blocking the forward implementation plan until backend answers them:

- Per-document call, or one batch call for the whole non-link set?
- Does the method respond synchronously with the resulting `Attachment`, or does the client need
  to await a later state change (poll or push)? This decides whether the "attaching" chip resolves
  on the method response or on a subsequent event.

## Sources

- [ADR-0095: External drive file picker integration](0095-external-drive-file-picker-integration.md)
- [ADR-0103: Attach Drive File as Attachment (Rejected)](0103-attach-drive-file-as-attachment.md)
