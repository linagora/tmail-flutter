# 0077 - Sentry Request Data Privacy

Date: 2026-04-03

## Status

Proposed

## Context

The `sentry_dio` integration automatically captures HTTP request metadata — headers, query string, and body — and attaches it to Sentry events. In Twake Mail, these fields can contain sensitive data:

- **Headers:** OAuth bearer tokens, session cookies, and API keys appear in `Authorization`, `Cookie`, and custom `X-Token` headers on every JMAP request.
- **Query string:** OIDC callback URLs carry `code` (authorization code) and `state` (anti-CSRF token) as query parameters. These are short-lived but still sensitive.
- **Body:** JMAP request bodies may contain message content or personal data.

The Sentry SDK also captures the current URL of the page (on web), which could include OAuth callback parameters.

## Decision

### 1. Strip sensitive headers

Remove headers whose names match known sensitive patterns before the event is sent. Matching is case-insensitive substring:

`authorization`, `cookie`, `set-cookie`, `x-auth`, `x-token`, `api-key`, `x-api-key`, `apikey`, `secret`, `bearer`, `session`, `password`, `token`

Implemented in `SentryInitializer._sanitizeHeaders()`, called from `_sanitizeRequest()` inside `beforeSend`.

### 2. Drop query string entirely

Rather than selectively redacting individual parameters — which is fragile as new OAuth parameters can be added — the `queryString` field is set to `null` on all Sentry request events.

If a specific query parameter is needed for debugging, it should be added explicitly as a Sentry tag at the relevant call site.

### 3. Drop request body

`data: null` in `_sanitizeRequest`. The body is never sent regardless of `maxRequestBodySize`.

### 4. Attach app URL (path only) as a tag

The current page URL is useful context for triaging errors — it shows which screen the user was on. The URL is attached as an `app.url` tag using **path only** (no query string, no fragment), ensuring no OAuth parameters are included.

Only applies on web (`http`/`https`). On mobile/desktop, `Uri.base` returns a `file://` path with no diagnostic value and is skipped.

## Consequences

**Benefits:**
- OAuth tokens and session credentials cannot leak into Sentry, even if the HTTP client is misconfigured.
- `app.url` tag gives screen context for every error event on web without exposing sensitive URL parameters.

**Trade-offs:**
- Query parameters are unavailable in Sentry for debugging. This is acceptable because the parameters relevant to debugging (e.g., JMAP mailbox IDs) should be logged explicitly via `extras` on `logError` call sites, not inferred from raw request URLs.
