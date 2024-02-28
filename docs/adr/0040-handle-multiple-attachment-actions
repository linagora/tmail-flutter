# 40. Handle multiple attachment actions

Date: 2024-02-28

## Status

Accepted

## Context

- Attachment can be tapped even if its previous action (download/view) is still handling
- When user tap one attachment multiple times, race condition can happen

## Decision

1. When an attachment is prepared to download/view:

- Tapping function of that attachment will be disabled
- The attachment icon in front of the attachment name will be replaced by a loading UI

2. When an attachment is downloaded/viewed:

- Tapping function of that attachment will be enabled
- The attachment icon in front of the attachment name will be returned

## Consequences

- The attachment button on Twake Mail will now only be tapped once per handling, improving performance & prevent multiple actions by mistake
