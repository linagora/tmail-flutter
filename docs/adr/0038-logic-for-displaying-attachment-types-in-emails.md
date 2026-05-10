# 38. Logic for displaying `attachment` types in emails

Date: 2024-02-20
Updated: 2026-05-12

## Status

Accepted

## Context

The logic for displaying attachments while reading emails is complex. Changes must be tracked here to avoid regressions across releases.

An **orphaned inline attachment** has `Content-Disposition: inline` + `Content-ID` but no matching `<img src="cid:...">` in the HTML body (common with Outlook/Word copy-paste). This caused orphans to be invisible to the reader and silently re-attached on every reply/forward.

## Decision

1. External attachments: Displayed as files outside the email content

- Display is only allowed when one of the following conditions is met:
  - `cid is NULL` AND `not in htmlBody` AND `does not satisfy this condition mimeType = 'application/rtf' && disposition = 'inline'`
  - `disposition != 'inline'` AND `not in htmlBody` AND `does not satisfy this condition mimeType='application/rtf' && disposition = 'inline'`

2. **Inline attachments** — displayed within the email body when:
   - `cid is not NULL` AND `disposition = 'inline' || disposition = NULL`

3. **Orphaned inlines** — inline attachments whose CID has no matching `<img src="cid:...">` in the body are **promoted to the attachment panel** (viewer) and **dropped on reply/forward** (composer), consistent with Thunderbird and Outlook behavior.

## Consequences

- Any changes to attachment display must be updated in this ADR.
- Orphaned inline attachments are visible in the attachment panel.

## References
- [rfc2392](https://datatracker.ietf.org/doc/html/rfc2392)
