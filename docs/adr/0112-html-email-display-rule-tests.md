# 0112. HTML email display rule tests

Date: 2026-10-20

## Status

Proposed (PR #4966)

## Context

Display regressions (overflow, squashed images, missing quote toggle, dropped lazy-load) were found by eye. Unit tests stayed green when a transformer was removed. Pixel goldens do not match the rules already encoded in the viewers.

## Decision

- Render every fixture through production `HtmlTransform` + `HtmlViewerDocumentBuilder` in Chrome at real pane widths: native 296/336/390/744, web 524/760/1000, iOS 296/336/390.
- Other viewers use their own widths and options: drafts 296/336/390/744, attachment 320/360/414/614, calendar native 232/272/326/680, calendar web 464/700/940, signature native 296/390, signature web 280, print 794 (A4).
- Each `htmlPipelineRegistry()` row names its rule sets; a row with none fails the contract test.
- Assert product rules: generic (overflow, image-fit, text, preservation, file cards) plus sidecar `expect` (`quoteToggle`, `lazyImages`, `autoScale`, `noScale`, `fullDisplay`, `noQuoteToggle`).
- No golden images. No production display change in the test PR.
- iOS EML previewer and the other viewers: generic rules only (no responsive script, no quote toggle).
- Print adds a rule: no lazy-loading marker left.
- Composer pipelines (VM tests): content preservation, idempotent second pass, no display-only markup, drive cards uneditable, `cid:` images restored on send, composer signature changes only `line-height`.
- Mutation tests (`-t mutation`) prove each rule can fail. CI: `html-display` runs `-t display` on every PR; `html-display-mutation` only when HTML paths change; `scripts/test.sh` excludes both tags.
- Add a case as `core/test/fixtures/html_emails/<category>/<name>.html` + `.json`, then `dart run tool/generate_html_email_corpus.dart`. Raw EMLs stay outside the repo; convert offline. How-to: `core/tool/README-html-email-fixtures.md`.
- Known product gaps live in `known_display_failures.dart` with a reason; a fix PR deletes its entries. Do not skip a new native failure.

## Consequences

- Opening a received mail on native/web is what this suite protects. Web attachment preview (external `TwakeHtmlPreviewer`) is not rendered. `loading="lazy"` is allowed in sent mail.
- Corpus is synthetic until the real-EML PR. Skipped iOS/web rows hide those gaps until unskipped.
