# 45. Memory leak with js lifecycle

Date: 2024-04-09

## Status

Accepted

## Context

- The js resources are disposed at the end of js lifecycle
- Current listener in used is `beforeunload`. However, `beforeunload` was unstable, resulting in memory leak.

## Decision

- `beforeunload` was replaced by `pagehide`, which is more reliable.
  - [`pagehide` documentation](https://developer.mozilla.org/en-US/docs/Web/API/Window/pagehide_event)
  - [Google Chrome recommendation](https://developer.chrome.com/docs/web-platform/page-lifecycle-api#the_unload_event)
## Consequences

- Memory leak problem in composer on TMail is resolved.
