# 38. Logic for displaying `attachment` types in emails

Date: 2024-02-20

## Status

Accepted

## Context

- The logic for displaying `attachments` while reading emails is complex
- Avoid unwanted loss of `attachments` with each new version release

## Decision

Brief the logic flows to make it easier to track changes during `attachment` display in emails:

1. External attachments: Displayed as files outside the email content

- Display is only allowed when one of the following conditions is met:
  - `cid is NULL` AND `not in htmlBody` AND `does not satisfy this condition mimeType = 'application/rtf' && disposition = 'inline'`
  - `disposition != 'inline'` AND `not in htmlBody` AND `does not satisfy this condition mimeType='application/rtf' && disposition = 'inline'`

2. Inline attachments: Displayed within the email body

- Display is only allowed when the following conditions are met:
  - `cid is not NULL` AND `disposition = 'inline' || disposition = NULL`

## Consequences

- Any changes to attachment display while reading emails should be updated in this ADR.

## References
- [rfc2392](https://datatracker.ietf.org/doc/html/rfc2392)