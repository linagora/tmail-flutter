# 36. Mailto URI schemes to interact Twake Mail

Date: 2024-02-19

## Status

Accepted

## Context

Supported URI schemes can be relied upon to interact with Twake Mail

## Decision

Summary of URI schemes that can interact with Twake Mail:

1. URI scheme

   - `/mailto?uri=user@example.com`
   - `/mailto/?uri=mailto:user@example.com&subject=TwakeMail&body=HelloWorld`
   - `/mailto/?uri=mailto:user1@example.com,user2@example.com,user3@example.com&to=user1@example.com,user2@example.com,user3@example.com&cc=user1@example.com,user2@example.com,user3@example.com&bcc=user1@example.com,user2@example.com,user3@example.com&subject=TwakeMail&body=HelloWorld`

2. URI scheme encoded

   - `%2Fmailto%3Furi%3Duser%40example.com`
   - `%2Fmailto%2F%3Furi%3Dmailto%3Auser%40example.com%26subject%3DTwakeMail%26body%3DHelloWorld`
   - `%2Fmailto%2F%3Furi%3Dmailto%3Auser1%40example.com%2Cuser2%40example.com%2Cuser3%40example.com%26to=user1%40example.com%2Cuser2%40example.com%2Cuser3%40example.com%26cc=user1%40example.com%2Cuser2%40example.com%2Cuser3%40example.com%26bcc=user1%40example.com%2Cuser2%40example.com%2Cuser3%40example.com%26subject%3DTwakeMail%26body%3DHelloWorld`

## Consequences

- Interact more easily with Twake Mail web via URI schemes
