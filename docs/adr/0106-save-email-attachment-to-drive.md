# 106. Save Email Attachment to Drive

Date: 2026-08-28

## Status

Proposed

## Reference

- Builds on [ADR-0095](0095-external-drive-file-picker-integration.md)
  (Drive token, workplace FQDN). Inverse of
  [ADR-0105](0105-attach-drive-file-via-jmap-mediated-upload.md)
  (Drive→Mail fetch). Mail BE shipped
  `unauthenticatedBlobAccess.adoc` (tmail-backend jmap-extensions).
  Drive import-from-URL is not documented yet.

## Context

Users save email attachments to Drive. Bytes must not transit the
Mail client (memory, double hop).

## Decision

- **BE-to-BE transfer.** Client mints a short-lived blob URL, then
  asks Drive to fetch and store it. Client never downloads or
  re-uploads bytes.
- **Mint via Mail BE.** Gate on session capability
  `com:linagora:params:jmap:unauthenticated:blob:access`. Call
  `UnauthenticatedBlobAccess/set` create keyed by `blobId` (empty
  object). Build GET URL from capability `endpoint` + returned
  `token`. TTL is server-set (`tokenTtlInSeconds`).
- **Hand off to Drive.** Authenticated Drive call with blob URL. 
  Drive GETs Mail within TTL and writes the file. 
- **No folder picker.** Drive writes to a well-known auto folder
  it owns. User organizes later in Drive.
- **Attachment UX.** Each attachment shows `Save to Drive` until
  lookup/save says it exists, then `See in Drive` (opens
  `openUrl`). Mail should store flags `save_to_drive_1`, 
  `save_to_drive_2`, `save_to_drive_*` to indicate attachments were save to Drive

## Consequences

- Client stays memory-flat; large files are a Drive/Mail TTL
  concern, not a client buffer.
- Blocked on Drive shipping import-from-URL, source lookup, and
  auto-folder (request/response schema TBD).

## Open questions

- Exact Drive endpoint, auto-folder name, and `openUrl` shape.
- Whether a later re-save should copy instead of being
  idempotent; default is idempotent.

## Sources

- tmail-backend `unauthenticatedBlobAccess.adoc`: https://github.com/linagora/tmail-backend/blob/master/docs/modules/ROOT/pages/tmail-backend/jmap-extensions/unauthenticatedBlobAccess.adoc
