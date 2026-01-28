# 70. Upload source maps to Sentry and GitHub Artifacts

Date: 2026-01-28

## Status

Accepted

## Context

- Minified JS in Sentry error reports is unreadable without source maps
- Source maps must not ship to production (exposes original code)
- Source maps must match the exact build deployed

## Decision

- Build Flutter web with `--source-maps` inside Docker (multi-stage)
- Extract `.map` files from Docker build stage via `docker cp`
- Upload to Sentry (`sentry-cli`) and GitHub Artifacts (30-day retention)
- Delete `.map` files in Docker runtime stage
- DRY `image.yaml` via reusable workflow (`build-web-image.yaml`)

## Consequences

- Readable Sentry stack traces
- Source maps guaranteed consistent with deployed build
- Final Docker image contains no `.map` files
- `image.yaml` reduced from ~208 to ~32 lines
