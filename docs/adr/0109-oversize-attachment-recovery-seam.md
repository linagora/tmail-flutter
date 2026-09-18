# 109. Oversize attachment recovery seam

Date: 2026-09-17

## Status

Accepted

## Context

- An attachment that exceeds the server size cap goes to Drive instead of a dead-end dialog.
- That upload is a Workplace call, so it rides the transport of ADR-0108.
- This decision covers the seam that upload plugs into; the upload call itself lands after.

## Decision

### Scope

- Prepared here: a recovery seam on the oversize path, a source-agnostic file body reader.
- Not here: the upload request, the magic folder, the link in the body.
- Nothing a user can see changes.

### One file body reader for both destinations

- A picked file is read the same way whatever uploads it.
- It streams from the file's path when the platform has a file system.
- It reads from the file's bytes otherwise, which on web is always.
- Streaming keeps a multi-gigabyte file off the heap, so mobile can attach one.
- On web the picker materialises the whole file before any reader runs
  (`withData: PlatformInfo.isWeb` in `local_file_picker_interactor.dart`).
- So the web ceiling is the browser heap, and lifting it is a picker change.
- A file carrying neither is an error, not a silently empty body.
- It is lifted out of the JMAP uploader's body builder, so both destinations share one reader.

### Recovery before the failure dialog

- A recovery is an alternative ending for a rejection.
- It takes the rejected files somewhere else and tells the user what happened.
- The first one, landing later, uploads the oversize files to Drive and links them in the body.
- The dialog is what shows whenever no recovery runs:
  - none is registered,
  - the rejection carries no files to act on,
  - or the registered recovery declines that failure.
- A recovery that takes over owns every user-visible outcome, failure toasts included.
- It never falls back to the dialog.

- Only a rejection on picked files reaches a recovery.
- `validateFiles` carries the picked files, so a recovery has the bytes to upload.
- `validateAttachment` re-attaches an existing JMAP attachment with no file behind it,
  so its rejections go straight to the dialog.
- The validation request carries the picked files, so a recovery knows what to act on.

```
on ValidationRejected(failure):
  if request.files.isNotEmpty and recovery?.recover(failure, request) == true:
    return false                     # recovery owns the UX from here
  feedback.showFailure(failure)      # today's dialog
  return false
```

- A recovery is registered as one optional builder argument on the upload validation service,
  built per rejection from the composer's context; no builder argument means today's dialog.
- No recovery is registered yet, so the dialog is still what every rejection shows.
- Drive availability for the oversize path is the same gate as the Drive picker button:
  workplace FQDN, ecosystem flag, user preference.
- Unavailable means today's dialog.

### Module boundary

- The main app owns the composer wiring, the recovery and the file body reader.
- `workplace` owns the transport it calls (ADR-0108).

## Consequences

- Adding an alternative to a blocking upload dialog is one class plus one builder argument.
- A recovery that takes over is alone responsible for telling the user what happened.
- On web an oversize file must fit in the browser heap; only the mobile path streams.

## Open questions

- How the uploaded file's shareable link is obtained.

## Sources

- [tmail-flutter#4827](https://github.com/linagora/tmail-flutter/issues/4827): attach too big file
- [ADR-0105: Attach drive file via JMAP-mediated upload](0105-attach-drive-file-via-jmap-mediated-upload.md)
- [ADR-0108: Workplace call transport](0108-workplace-call-transport.md)
