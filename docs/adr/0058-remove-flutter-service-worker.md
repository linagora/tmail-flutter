# 58. Remove Flutter Service Worker

Date: 2024-11-26

## Status

Accepted

## Context

- Flutter Service Worker have many issues regarding updating cache resources
  - https://github.com/flutter/flutter/issues/104509
  - https://github.com/flutter/flutter/issues/63500
- Flutter is moving away from Flutter Service Worker
  - https://github.com/flutter/flutter/issues/156910

## Decision

- We remove the Flutter Service Worker and let the browser handle the cache by:
  - Remove the Flutter Service Worker initialization
  - Remove the existing Flutter Service Worker registration

## Consequences

- Twake Mail web now will validate cache with the server every time it is loaded
  - If the status code is 200, new resources will be fetched
  - If the status code is 304, old resources will be used
- All of the existing service workers will be removed, even if it is not Flutter Service Worker
