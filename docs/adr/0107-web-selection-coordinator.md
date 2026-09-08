# 0107. One coordinator for Flutter and iframe text selection on web

Date: 2026-09-08

## Status

Accepted

## Context

On web, Flutter text such as the email subject is selected through a
`SelectionArea` in the top document. The email body and the composer editor
are `srcdoc` iframes with their own native selection and their own DOM focus.
The two selection systems are invisible to each other, so once an iframe has
been clicked the native right-click "Copy" can be disabled or copy the wrong
region's text.

The app's iframes are unsandboxed `srcdoc` documents and therefore
same-origin with the top document: their selection can be read and cleared
from Dart directly.

## Decision

- A single app-wide coordinator, started once at web boot, keeps Flutter's
  selection and every iframe's native selection mutually exclusive.
- No widget, controller, or iframe registers with it. A `SelectableRegion`
  requests focus when a selection starts, which is observed through
  `FocusManager`. Focus moving into any iframe is observed through the top
  window's `blur` event.
- When a `SelectableRegion` takes focus, every `<iframe>` in the document,
  including the composer editor, has its selection ranges removed; an iframe
  holding DOM focus hands it back to the Flutter view element.
- When the top window blurs and the active element is an iframe, the
  `SelectableRegion` holding Flutter focus is cleared and unfocused.
- Browser access sits behind an adapter interface with a no-op stub on
  non-web builds and in tests.

## Consequences

- Right-click "Copy" always targets the highlighted region.
- Clicking or selecting in one region deselects the other, matching standard
  single-selection browser behaviour.
- A new iframe or a new `SelectionArea` takes part automatically.
- A cross-origin iframe only loses DOM focus, since its selection cannot be read.
- Non-web platforms are unaffected.
