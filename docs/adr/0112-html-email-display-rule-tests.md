# 0112. HTML email display rule tests

Date: 2026-10-20

## Status

Proposed (PR #4966)

## Context

Display regressions (overflow, squashed images, missing quote toggle, dropped lazy-load) were found by eye. Unit tests stayed green when a transformer was removed. Pixel goldens do not match the rules already encoded in the viewers.

## Decision

- Render every fixture through production `HtmlTransform` + `HtmlViewerDocumentBuilder` in Chrome at real pane widths: native 296/336/390/744, web 524/760/1000, iOS 296/336/390.
- Assert product rules: generic (overflow, image-fit, text, preservation, file cards) plus sidecar `expect` (`quoteToggle`, `lazyImages`, `autoScale`, `noScale`, `fullDisplay`, `noQuoteToggle`).
- No golden images. No production display change in the test PR.
- iOS EML previewer: generic rules only (no responsive script, no quote toggle).
- Mutation tests (`-t mutation`) prove each rule can fail. CI: `html-display` runs `-t display` on every PR; `html-display-mutation` only when HTML paths change; `scripts/test.sh` excludes both tags.
- Add a case as `core/test/fixtures/html_emails/<category>/<name>.html` + `.json`, then `dart run tool/generate_html_email_corpus.dart`. Raw EMLs stay outside the repo; convert offline. How-to: `core/tool/README-html-email-fixtures.md`.
- Known product gaps live in `known_display_failures.dart` with a reason; a fix PR deletes its entries. Do not skip a new native failure.

## Consequences

- Opening a received mail on native/web is what this suite protects. Composer, print, calendar, and `forReplyForwardEmptyEmail` are not in it.
- Corpus is synthetic until the real-EML PR. Skipped iOS/web rows hide those gaps until unskipped.
