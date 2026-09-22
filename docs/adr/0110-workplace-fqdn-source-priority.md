# 110. Workplace FQDN Source Priority

Date: 2026-09-18

## Status

Proposed

## Context

The Workplace FQDN drives the paywall CTA and the Drive attachment picker.

It arrives from more than one place, on independent schedules, and each place may have nothing to offer.

The OIDC `/userInfo` `workplaceFqdn` claim is the authoritative per-user value, but some deployments never serve it.

`.well-known/linagora-ecosystem` can carry a per-deployment `workplaceFqdnFallback` template resolved against the signed-in address.

Neither source has a guaranteed arrival order: the ecosystem document and the `/userInfo` response race.

## Decision

One provider per source, each holding only its own value, each normalizing its own raw input, all exposing the same single-setter API.

An ordered list of those source providers, highest priority first: OIDC `/userInfo`, then ecosystem fallback.

One derived provider observes every source and exposes the first non-null in list order; it is the only value consumers read.

Priority is list position, not code branching — a new source is a new provider plus a list entry.

Because every source is observed, a higher-priority source that resolves late takes over automatically, and clearing it falls back down the list.

A source that resolves to a blank or unparseable value contributes nothing, so the next source is used.

## Consequences

Each source is independently inspectable and independently overridable in tests.

Consumers keep reading a single `String?` and are unaware of how many sources exist.

Adding an env-config or deep-link source later touches no existing source and no consumer.

Priority is expressed in exactly one place, so a reordering is a one-line change.

Every source provider is `keepAlive`, so a source's state survives logout. Each source
must be explicitly reset (or overwritten) on logout and on sign-in for a new account,
otherwise a stale higher-priority value from the previous account keeps winning. This
reset, plus a regression test for account switching, is a required follow-up for whichever
PR wires the source providers into the logout/sign-in flow.
