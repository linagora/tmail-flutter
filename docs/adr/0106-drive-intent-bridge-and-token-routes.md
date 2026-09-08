# 106. Two routes to a Drive intent behind one fetcher abstraction

Date: 2026-09-08

## Status

Accepted

## Context

A Drive PICK intent is reachable in two ways, depending on where TMail runs.

Inside the Twake Workplace container on web, `cozy-external-bridge` (1.3.0 or later) attaches
`fetchJSON` to the page. It proxies the request through the container app, which already holds the
stack session. No token is involved.

Everywhere else (standalone web, mobile, tablet), TMail exchanges its OIDC `id_token` for a Drive
access token and calls `/intents` directly with a bearer header.

The two routes differ in transport, authentication and availability, and share only their input
(platform URL plus picker configuration) and output (a `WorkplaceIntent`).

## Decision

One abstraction, `DriveIntentFetcher`, exposes `isAvailable` and `fetchIntent`.

Two implementations, each owning its full stack down to the datasource:

- **Bridge route** — available when the bridge exposes `fetchJSON`; sends the request through it.
  This is the only code in the package that touches JS interop.
- **Token route** — always a candidate; obtains the OIDC `id_token` from a getter injected by the
  app, exchanges it, then calls `/intents` over HTTP with the bearer token. The whole token
  lifecycle lives here.

A fallback fetcher takes an ordered list of fetchers, uses the first available one, and hands over
to the next on error. Only the last available fetcher's error reaches the caller. The composer
extension composes bridge first, then token.

Request body and response parsing are shared by both routes through one mapper, so Drive receives
the same shape whichever route carries it.

The app layer (`lib/`) knows neither route. It supplies the platform URI and the OIDC token getter
and receives a `WorkplaceIntent`.

## Consequences

- A route is added, removed or reordered without touching the others.
- Token concerns (exchange, and later prefetch or refresh) have exactly one home.
- The fallback policy is a pure object and is unit-tested with fake fetchers on the VM; only the
  bridge datasource needs a browser test.
- ADR-0095 Steps 2 and 3 describe the per-route request details.
