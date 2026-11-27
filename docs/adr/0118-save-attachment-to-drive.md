# 118. Save an attachment to Twake Drive

Date: 2026-11-27

## Status

Proposed

## Reference

- [#4791](https://github.com/linagora/tmail-flutter/issues/4791) Save to my Drive
- [#4795](https://github.com/linagora/tmail-flutter/issues/4795) ADR - Save to my Drive

## Context

- A user saves an email attachment to their own Twake Drive.
- The file lands in the `Mail` folder, and the user can move it afterwards.
- The bytes never pass through the device.
- tmail-backend gives a short-lived download URL for a blob.
- cozy-stack can fetch a file from a URL into a folder.
- Web and mobile call Drive through the Workplace transport of [ADR-0108](0108-workplace-call-transport.md).

## Decision

### Flow

- Token: `UnauthenticatedBlobAccess/set` for the blob gives a token.
  The capability `endpoint` template turns it into the download URL.
- Save: `POST /files/io.cozy.apps%2Fmail?Type=file&Name=<name>&SourceURL=<url>` on the user's stack.
  The stack downloads the file from tmail-backend, server to server.
- Reference: the stored file gets `io.cozy.mails.attachments` `<accountId>:<emailId>:<blobId>`.
- Organize: the Drive MOVE intent, opened on the folder of the saved file, with the button label "Save to".
- Saved state: when an email opens, the app reads the references of each attachment.
  A file found shows "See in Drive", otherwise "Save to my Drive".

### Rules

- Files save one at a time.
  A token is requested just before each file, because a new token ends the previous one for the same blob.
- The actions show when the shown account supports the capability and the Workplace is known.
  There is no feature flag.
- The shown account owns the blob.
  The token request and the reference use its `accountId`.
  The destination is always the user's own Drive.
  A team mailbox follows the account that holds it.
- The save is confirmed only when the stored size equals the attachment size.
  Any other result is "unconfirmed".
- An unconfirmed save is never retried by the app: the file may still land.
- Web inside the Cozy Mail app uses the bridge without replaying on the bearer token.
  Standalone web and mobile use the bearer token, one exchange per batch.
- A failed reference write does not fail the save.
  A failed reference read shows "Save to my Drive".

### Errors

| Cause | The user sees |
|---|---|
| Capability missing | no action shown |
| Token refused for the blob | Drive access denied |
| Stack could not fetch the URL, timeout, size mismatch | Could not confirm the save, check Drive |
| Drive full | Your Drive is full |
| Drive refused the write | Drive access denied |
| Organize could not open | error with Retry |

### UI

- A compact chip per attachment with three states: save, saving, saved.
- "Save all to Drive" in the attachments header.
- One success toast with "Organize" and a close button, in the success green of the design.
- Design: Figma Teammail 1.1, node `11884:12035`, first three frames.

## Consequences

- Saving needs no intent frame; only Organize uses one.
- Deployment needs the blob access extension with Redis, a route for `/unauthenticatedDownload`,
  and a stack that can reach that URL and supports `SourceURL`.
- The stack limits a download to 10 s, which bounds the size of a saved file.
- The `mail` app manifest needs the grants for the reference write and read.

## Open questions

- Which manifest grant lets the app add the reference.
- Whether the server issues a token for a delegated `accountId`, and whether it lists the capability per account.
  Both are checked on the real backend; the app handles every outcome.

## Sources

- [ADR-0108: Workplace call transport](0108-workplace-call-transport.md)
- [ADR-0114: Delegated mailbox access](0114-delegated-mailbox-access.md)
- [tmail-backend: Unauthenticated Blob Access](https://github.com/linagora/tmail-backend/blob/master/docs/modules/ROOT/pages/tmail-backend/jmap-extensions/unauthenticatedBlobAccess.adoc)
- [cozy-stack: upload from a source URL](https://github.com/linagora/cozy-stack/pull/4968)
- [Twake Drive: reference and label on intents](https://github.com/linagora/twake-drive/pull/4662)
