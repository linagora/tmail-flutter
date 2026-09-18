# 111. Migrate to file_picker 13 for streamed picks

Date: 2026-09-18

## Status

Accepted

## Context

- Picking a file on web read all of it into the Dart heap, then file_picker wrapped those bytes
  in a second `Blob` for its object URL. About twice the file size resident.
- The conversion to `FileInfo` dropped that object URL, so the second copy was never revoked and
  stayed for the tab's lifetime.
- The pick ran before any size check, so an oversize file paid the whole cost before being
  rejected by the size dialog.
- The damage band is roughly 500 MB to 2 GB. Above it the browser refuses the buffer, the read
  returns nothing, and a file with no bytes flows on.
- Mobile was never affected: it picked into 1 MB slices.
- Issue #4827 attaches oversize files, so every pick on that path sits in the damage band.
- file_picker 10 offered only a single-use read stream. A 401 mid-upload has to replay the body,
  and a drained stream cannot be replayed, so streaming and retry could not both hold.
- Fixing only the pick moves the whole-file copy rather than removing it: the HTTP client's web
  adapter accumulates a request body stream into one buffer, grows that buffer past the file's own
  size, copies it twice more and only then sends. An upload on web therefore materialises the file
  at several times its size before the first byte leaves the browser.
- A request body supplied as a stream of bytes cannot avoid that. `XMLHttpRequest` given a blob
  can: the browser reads it from disk into the request itself, and that has been true in every
  browser for many years.

## Decision

### A picked file is a source that can be opened, not bytes that were read

- `FileInfo` carries `openRead`, a function returning a fresh `Stream<List<int>>`.
- A factory, not a stream: every caller opens its own body, so a replay always has one.
- It is excluded from equality — a function has no value.
- `FileInfo.readBytes()` collects a whole file into memory. Only inline images use it, and they
  are small by construction. A picked attachment is streamed and never collected.
- The guarantee is scoped to source-backed files. An attachment that arrives as bytes instead — a
  web dropzone drop, an inline image, a Drive re-attach — has no source to open, so it stays
  resident exactly as it does today. Those paths are small by construction; the picker was the one
  that was not.

### One upload body path

- The uploader resolves a body in one order: the factory, then a local file path, then retained
  bytes, otherwise a missing-source failure.
- The request extra carries that factory under a single key. The previous pair of keys, one for a
  path and one for a prebuilt stream, is gone.
- The 401 replay is one path for web and mobile: open a new body from the factory and refetch the
  original request options, which keeps the progress callback, cancel token, timeouts and
  response type. No body means the attachment fails loudly rather than storing a zero-byte blob
  under its name.
- Charset detection opens its own body, takes a 256 KiB head and stops, so probing a 1 GB text
  attachment costs one short read rather than a second full pass.

### file_picker types stop at the picker boundary

- `PlatformFile` reaches exactly one place, the extension that converts it to `FileInfo`.
- Composer, identity creator and public asset controllers take `FileInfo`.
- The reverse conversion and the list-of-picked-files size helper are gone; total size comes from
  the `FileInfo` list helper that already existed.

### Web reads nothing at pick time

- Web picking is configured to request neither bytes nor a read stream, chosen through a
  conditional import so non-web platforms carry no web configuration at all.
- file_picker then keeps an object URL over the browser's own file handle. Nothing is resident at
  pick time, and each read re-opens that URL, which is what makes a replay possible.

### Web sends the file, not its bytes

- `FileInfo` carries the picked file's source URL alongside the factory. On web that is the object
  URL; elsewhere it is absent.
- A web-only HTTP adapter recognises an upload carrying that URL, resolves it back to the blob and
  hands the blob to the request directly. The body stream is never read, so nothing accumulates.
- Every other request on web keeps the default adapter's behaviour: the override falls through to
  it whenever the marker is absent.
- Upload progress is unaffected — it is reported by the request's own upload events, which a blob
  body raises exactly as a byte body does.
- A 401 replay re-sends the same request description; the adapter resolves the URL again, so there
  is nothing to rebuild.
- The byte-stream path stays as the fallback for any web upload with no source URL, and is the only
  path on mobile.

### Version floor

- file_picker 13.1.0, with file_picker_web as a direct dependency for its web options type.
- Dart SDK floor 3.10.0 across the three workspace pubspecs, and the bumps pub resolution then
  required: device_info_plus 13.2.0, share_plus 13.3.0, mime 2.0.0, package_info_plus 10.2.1,
  win32 6.4.0, xml 6.6.1.
- Two Linagora forks follow the same floor and are pinned to their migration branches until the
  fork pull requests merge.

## Consequences

- A large picked web attachment uploads with flat resident memory: nothing is read at pick time,
  and the browser streams the blob into the request at send time. A dropped file carries no source
  URL, takes the byte path and keeps the cost it has today.
- Rejecting an oversize file costs nothing: the size comes from the file handle, not from bytes.
  That is the path issue #4827 takes, and it never reaches the network layer at all.
- A 401 mid-upload can now be replayed on web, which the previous web path could not do.
- Web carries a hand-written HTTP adapter for one narrow case. It delegates to the default adapter
  for everything else, but it is code that follows the HTTP client's browser adapter and has to be
  revisited when that is upgraded.
- The memory test measures the VM's adapter. It proves the uploader holds nothing, not that the
  browser does; the web claim rests on manual measurement per browser.
- The platform interface instance is the seam for a test double, and the picked-file type is
  abstract, so a fake implements it rather than constructing one.
- share_plus 13 replaces the top-level share call with an instance taking a parameters object;
  trace log export follows it.
- Two pubspec entries point at fork branches, so the app builds from a moving ref until those
  merge and the entries return to their default branches.
- The object URL is deliberately never revoked. The factory re-fetches that URL on every read, so
  revoking it would break the 401 replay and any later preview; ownership would have to be shared
  between the uploader, the retry path and the composer, and none of them can know it is last.
  Retention is one registry handle per pick, held until the tab closes — bounded, and no longer
  scaling with file size the way the old byte copy did.

## Open questions

- Whether a file edited on disk after being picked can fail its re-read on web, since the object
  URL resolves lazily. Mobile reads from a path and has the same exposure today.
- Whether resolving an object URL back to a blob keeps the browser's disk backing rather than
  copying it into memory. It is a handle into the blob registry and should, but the claim of flat
  memory rests on it, so it is measured per browser rather than assumed.

## Sources

- [tmail-flutter#4827](https://github.com/linagora/tmail-flutter/issues/4827): attach too big file
- [linagora/html-editor-enhanced#71](https://github.com/linagora/html-editor-enhanced/pull/71): file_picker 13 migration
- [linagora/intl_generator#6](https://github.com/linagora/intl_generator/pull/6): petitparser 7 / xml 6 upgrade
- [ADR-0106: Root isolate attachment upload authentication](0106-root-isolate-attachment-upload-authentication.md)
- [ADR-0109: Oversize attachment recovery seam](0109-oversize-attachment-recovery-seam.md)
