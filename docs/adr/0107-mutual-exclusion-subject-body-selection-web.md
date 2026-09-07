# 0107. Mutual exclusion between subject and email body selection on web

Date: 2026-09-07

## Status

Accepted

## Context

On web, the email subject is selectable through a single app-wide Flutter
`SelectionArea`, while the email body is a real `srcdoc` `<iframe>` with its
own native browser selection and its own `document.activeElement`. The two
selection systems are invisible to each other. Interacting with the iframe
— even a plain click, with no selection made there — leaves the top
document's real focus and the `SelectionArea`'s active-selection state
stale without clearing its visual highlight, so the native right-click
"Copy" can show disabled, missing, or targeting the wrong region's text
depending on browser.

## Decision

- A selection starting in either the Flutter `SelectionArea` or an email
  body iframe clears the other, so only one selection is ever active.
- `HtmlSelectionSyncBus` (`core/lib/presentation/views/html_viewer/`)
  broadcasts `flutterSelectionStarted` and `iframeSelectionStarted` events
  between the two sides.
- Each email body iframe listens for `document.selectionchange`; a
  non-empty selection notifies the bus and a `toIframe: clearSelection`
  message (removeAllRanges) clears it when the other side reports a
  selection.
- The thread detail body's `SelectionArea` reports its own selection
  changes to the bus and clears itself via `SelectionAreaState.selectableRegion.clearSelection()`
  through a `GlobalKey` held on `ThreadDetailController`.
- When a Flutter-side selection starts, each iframe also blurs itself
  (`IFrameElement.blur()`), returning real DOM focus to the top document
  regardless of whether the iframe ever held a selection.

## Consequences

- Right-click "Copy" always targets whichever region is actually
  highlighted, on both Chrome and Firefox.
- Selecting text in one region now visibly deselects the other, matching
  standard single-selection browser/webmail behavior.
- Non-web platforms are unaffected — the bus and iframe hooks are gated
  behind `PlatformInfo.isWeb`.
