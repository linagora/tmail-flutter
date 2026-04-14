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

### 2. Keep query string

The `queryString` field is retained in Sentry request events. For JMAP API calls — which form the vast majority of requests — query parameters carry no sensitive credentials and provide useful context for triaging errors. OAuth callback parameters (`code`, `state`) are short-lived and appear only in the narrow OIDC login flow; the debugging benefit of retaining query context across all other requests outweighs this limited risk.

### 3. Drop request body

`data: null` in `_sanitizeRequest`. The body is never sent regardless of `maxRequestBodySize`.

### 4. Attach app URL as a tag

The current page URL is useful context for triaging errors — it shows which screen the user was on and, where relevant, which query parameters were active. The URL is attached as an `app.url` tag using **path and query string** (no fragment), consistent with the decision to retain query parameters in section 2.

Only applies on web (`http`/`https`). On mobile/desktop, `Uri.base` returns a `file://` path with no diagnostic value and is skipped.

## Consequences

**Benefits:**
- OAuth tokens and session credentials cannot leak into Sentry, even if the HTTP client is misconfigured.
- `app.url` tag gives screen context for every error event on web without exposing sensitive URL parameters.

**Trade-offs:**
- Query parameters are retained in Sentry for request/app URL context; this carries a limited, accepted risk (notably short-lived OIDC `code`/`state` in a narrow flow), mitigated by header/body sanitization and the short lifetime of those tokens.
