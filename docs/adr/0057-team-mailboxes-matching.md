# 57. Team Mailboxes Matching

Date: 2025-02-18

## Status

Accepted

## Context

- Team mailboxes were not considered when sending emails
- Sent emails were saved to default sent mailbox, although selected identity's email was based on team mailbox email

## Decision

- Instead of hard coding default sent mailbox, sent emails will be saved to mailbox based on
  - identity's email
  - mailbox's name (hard coded English)
- Only when there's no matching mailbox, default sent mailbox will be used
- Same logic is applied to drafts mailbox and outbox mailbox

## Consequences

- Team mailboxes will be considered when sending emails
- Potentially, if team mailboxes existed but the name is not in English, sent emails will be saved to default sent mailbox
