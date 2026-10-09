# 113. Test HTML email display in three layers

Date: 2026-10-09

## Status

Proposed

## Context

- Display bugs reach users first; review cannot see layout.
- The tests change no app behaviour.

## Decision

- Locks: golden files pin the sanitizer policy, each pipeline and each viewer document; registry contracts check sanitizing.
- Rules: every fixture is rendered like the app, in Chrome, at real pane widths, and checked by rules. Mutation proofs show each rule can fail.
- Real emails: anonymized real mail as fixtures. Emails that show a bug stay red; all bugs are in one list.

## Test flow and structure

Paths are under `core/`; fixtures, goldens and tools are shared by all tests.

```
fixture .html + .json sidecar        test/fixtures/html_emails/<category>/
  │                                  (built into a corpus by tool/)
  │
  ├─▶ production pipeline (per viewer) ◀── golden locks, registry contracts,
  │                                        content preservation
  ├─▶ offline image swap (same-size SVG)
  ├─▶ production document builder      ◀── viewer-document locks
  ├─▶ Chrome iframe at each pane width
  └─▶ generic rules + expect checkers   ◀── mutation proofs (can each rule fail?)
```

| Test | Question it answers | Code (`test/utils/`) | CI job |
|---|---|---|---|
| Golden locks | Did sanitizer, pipeline or viewer output change? | `html_locks/` (goldens in `test/fixtures/html_locks/`) | `analyze-test` |
| Registry contracts | Is each pipeline sanitized as its input requires? | `html_pipeline_registry.dart`, `transform_configuration_contract_test.dart` | `analyze-test` |
| Content preservation | Did a pipeline lose words or links? | `html/display_rules/content_preservation*` | `analyze-test` |
| Generic rules | Does any email look broken? | `html/display_rules/generic_rules*`, rendered by `html/display_harness/` | `html-display` |
| Expect checkers | Does this email behave as its label says? | `html/display_rules/expect_checkers*` | `html-display` |
| Mutation proofs | Can each rule actually fail? | `html/display_rules/mutation_proof_browser_test.dart` | `html-display-mutation` |

| Viewer | Pipeline | Pane widths |
|---|---|---|
| Web | `forPreviewEmailOnWeb` | 524 / 760 / 1000 |
| Native | `forPreviewEmail` | 296 / 336 / 390 / 744 |
| iOS previewer | `forPreviewEmail` | 296 / 336 / 390 |
| `text/plain` (all viewers) | `forPlainTextEmail` | same as the viewer |

Reply, drafts, print, signature and calendar pipelines are not rendered; locks and registry contracts cover them.

## Test types

**Golden locks**
- How: probe inputs go through the code; the result is compared with a committed file (sanitizer keep/drop per tag, attribute, CSS and URL scheme; transformer list; one probe output; viewer documents).
- Fails when: any output changes.
- Update: `UPDATE_HTML_LOCKS=true`, then the reviewer reads the diff.

**Registry contracts**
- How: every `TransformConfiguration` factory has a row with its input trust (raw / sanitized / user); a test fails if a factory has no row.
- Fails when: raw input is not sanitized, sanitized input is sanitized twice, or an XSS probe survives.
- Known gap: skipped with its reason.

**Content preservation** (VM)
- How: each fixture runs through each display pipeline.
- Fails when: fewer than `minPreservation` of the words survive (counted per occurrence), or links or their destinations change (except links the sanitizer is meant to drop).
- `text/plain`: every web address must become a link.

**Generic rules**
- How: every fixture × viewer × width, again with the quote expanded.
- Fails when: something overflows the pane or scrolls sideways (G-overflow), an image does not fit or is squashed (G-image-fit), nothing is visible (G-text), or a line-height, word-split, ASCII-table, link-fill or RTL rule breaks.
- Report: CSS path + pixels.

**Expect checkers**
- How: only for the labels in the sidecar `expect`.
- `fullDisplay`: everything shows, within the native height cap. `lazyImages`: lazy until scrolled, then the right source.
- `autoScale` / `noScale`: an overflowing email is reflowed or zoomed, a fitting one is left alone. `quoteToggle`: the button exists, collapses, expands.

**Mutation proofs**
- How: break one mechanism in the test only (transformer, CSS rule, script, quote toggle, fake sanitizer loss), then render the affected fixtures.
- Fails when: no new violation (rule + element) appears.
- Tagged `mutation`, skipped by default.

**Real emails** (input, not a test type)
- How: `eml_to_fixture.py` replaces words with same-length real words, URLs / images / IDs with placeholders, and sender names inside CSS identifiers consistently.
- Kept byte-identical: tags, attribute names and order, sizes, colors, CSS rules.
- Checked by: local diff + Chrome render vs the original (counts only), then human privacy review.
- Emails showing a bug stay red and are listed in the bug list.

## CI

- `analyze-test`: VM + Chrome tests, skips tags `display`, `mutation`.
- `html-display`: matrix native / web / ios.
- `html-display-mutation`: only when HTML paths change.

## Consequences

- Pro: a regression names the element; each mechanism is proven.
- Con: Chrome only. Not covered: WKWebView / Android WebView rendering, and the widget's runtime behaviour (height reporting, scroll), which has its own widget tests.
- Con: `html-display` stays red until listed bugs are fixed.
