# HTML email display fixtures

Fixtures live in `core/test/fixtures/html_emails/<category>/<name>.html` with a
`<name>.json` sidecar. `html_email_corpus.g.dart` is generated from them.

## Convert a real EML (local only, never on CI)

The raw `.eml` stays **outside the repo** (the tool refuses a path inside it)
and is never copied. The converter is Python stdlib only and fully offline: it
never fetches an image or opens a socket.

```sh
cd core
# 1. Privacy report only, nothing written
python3 tool/eml_to_fixture.py ~/mails/x-12.eml --id 12 --dry-run
# 2. Write the fixture
python3 tool/eml_to_fixture.py ~/mails/x-12.eml --id 12 \
  --category newsletter_builders --name promo_two_columns \
  --purpose "two-column promo that must stack on phones" \
  --expect fullDisplay,lazyImages
```

What it does:

- Body: `text/html`, else `text/plain` (sidecar `contentType: "text/plain"`).
  A plain-text body is still written to `<name>.html`.
- Images (including `data:` images) become `https://fixture.invalid/{img|cid|est}/<W>x<H>` (`est`: a guessed size).
  CID and `data:` sizes are read from the image bytes. Remote sizes come from the `width`/`height` attributes,
  then the inline CSS, then the containing `td`/`table` width, then 600x300.
  The sidecar's `imageSizes` counts each source, so `container` and `default`
  mark sizes that are estimates.
- Visible text (and text in comments and in `alt`, `title`, `aria-label`...) is
  replaced word by word with real but unrelated words of the same length and
  case (`tool/fixture_words.py`: English for unaccented words, Vietnamese
  syllables for accented ones, picked to render about as wide as the original);
  other scripts get random letters of the same script, digits random digits.
  Names, companies, addresses and numbers in the text are gone; spaces, line
  breaks and punctuation stay, so the layout stays.
- Attribute URLs (`href`, `src`, `srcset`, `background`, CSS `url()`...) become
  stable placeholders; `mailto:`/`tel:`/`sms:`/`geo:`/app schemes keep only the
  scheme. Images become `https://fixture.invalid/{img|cid|est}/<W>x<H>` (`est`: a guessed size).
- Sender names and domain words inside CSS identifiers (`class`, `id`,
  selectors, font names) are renamed consistently with same-length letters, so
  selectors still match; CSS words, hex colors and function names are never
  renamed. `*-id` values are masked; phones and long numbers in `data-*` and
  `<meta>` values are zeroed; email addresses anywhere become placeholders.
- Everything else is kept byte for byte: tags, attribute names and order,
  `style`, sizes, colors, `<style>` CSS (also inside MSO conditional comments),
  `<meta>` rendering hints, namespaces.
- The same EML always gives byte-identical output (any process, any hash seed).

## Review before committing

Verify the conversion against the originals (local, prints counts only):
compare tag sequence, attribute names and values, CSS and text shape
(every word length and whitespace position) between each EML body and its
fixture, and render both in Chrome with the same images to compare element
boxes. For the 37-email set: 0 unexpected differences; identical structure
and overflow at 360 and 1000px; widths differ only where boxes size to text
(the replacement words are not pixel-identical).


- The console report must show `LEFTOVER ... 0` for every row: hosts, emails,
  long numbers and phone numbers left in attribute values or CSS (the text
  itself is replaced). Otherwise run
  again with `--show-samples` (prints the values locally, may show private data)
  and fix them by hand in the `.html`.
- Skim the `.html` for names, subjects, order numbers or tracking IDs that are
  still in the text.
- If a layout check fails only because of a `default`-sized image, set the real
  size by hand in the placeholder URL and say so in `purpose`.

## Sidecar

```json
{
  "source": "eml #12, anonymized",
  "purpose": "two-column promo that must stack on phones",
  "contentType": "text/html",
  "expect": ["fullDisplay", "lazyImages"],
  "minPreservation": 0.95,
  "imageSizes": {"cid": 0, "data": 0, "attr": 6, "css": 0, "container": 2, "default": 0}
}
```

`expect` values: `fullDisplay`, `lazyImages`, `autoScale`, `noScale`,
`quoteToggle`, `noQuoteToggle` (the `HtmlEmailExpect` enum; the generator rejects any other value).
Older fields still work: `expectQuote`, `rtl`, `allowEmptyBody`.

## Regenerate and test

```sh
cd core
fvm dart run tool/generate_html_email_corpus.dart
fvm flutter test test/fixtures/html_emails
python3 -m unittest discover -s tool -p 'test_*.py'
```

## Pending display bugs (the only list)

Every display bug found by these tests, in one place. Fixtures that show a
bug are committed red on purpose (decision: the email documents the bug; its
fix PR turns it green). Fixtures: `eml_N` = `real/eml_N`, others are paths
under `core/test/fixtures/html_emails/`. Viewers: `n` native, `w` web,
`i` iOS previewer, with pane widths. Status as of 2026-10-08.

| # | Bug | Fixtures | Where | Status |
|---|---|---|---|---|
| 1 | Native responsive script leaves the email overflowing | eml_1, eml_8 (296), eml_12, eml_20 | n296–n744 | open |
| 2 | iOS previewer has no image normalize / responsive script: wide content overflows | eml_1, 2, 6, 7, 8, 9, 11, 12, 13, 16, 19, 20, 23, 29, 31, 32, 34, 35, 36, 38, 39, 40, 43; `layout_stress/wide_image`, `newsletter_builders/mailchimp`, `expect_checks/auto_scale_*`, `expect_checks/quote_toggle_wide` | i296–i390 | open |
| 3 | Web does not fit wide content: no responsive script, the 600px media query only resizes tables (wide tables above 600px, fixed-width wrapper `div` at any width) | eml_1, 2, 6, 8, 12, 20, 29, 34, 35, 36, 38, 40, 43; `layout_stress/wide_table`, `expect_checks/auto_scale_*`, `expect_checks/quote_toggle_wide` | w524–w1000 | open |
| 4 | Image wider than the pane | eml_16, 23, 40 (iOS); eml_2, 34, 40 (web 760) | i296–i390, w760 | open |
| 5 | Image squashed: the normalize script sets `max-width:100%` but keeps a fixed `height` (also for `em`/`rem`/`%` sizes) | eml_6, 13, 15, 31, 36 | n, w524 (eml_15 also i) | open |
| 6 | Quoted text below 13px at ≤ 480px: the rule sets 13px on the `blockquote` only, inner inline sizes win | eml_6, 12, 43 | n296–n390 | open |
| 7 | Expanded quote overflows the pane (eml_20: 31 nested `blockquote` levels) | eml_12 (296–390), eml_20 | n296–n744 | open |
| 8 | Image never shown (0×0): sender lazy-loading with only `data-src` | eml_28; also eml_13, 36 at some widths | n, w | open |
| 9 | Body taller than the native viewer cap (`ConstantsUI.htmlContentMaxHeight`) | eml_20 | n744, w760 | open |
| 10 | Plain-text ASCII table in a `white-space: pre` block overflows | eml_35 | i, w | open |
| 11 | Plain-text ASCII table next to prose is not detected (`StringConvert.isTextTable` needs every line to be table art): proportional font, columns misalign | `edge/plain_text_table` | n, w, i | open |
| 12 | Word cut mid-letters in a table cell: `ResponsiveTableCellTransformer` adds `overflow-wrap: anywhere`, so a column shrinks below its longest word, even at 1000px. It also makes `table, td, th { word-break: normal }` dead CSS. eml_7 on native: the responsive script sets `word-break`. A fix must keep long URLs from overflowing (`layout_stress/long_url_cell`). | eml_11, 17, 29, 31, 36, 39, 7; `layout_stress/word_and_prose_columns` | n, w, i | deferred (Dat, 2026-10-08) |
| 13 | The sanitizer drops `td` attributes (`width`, `colspan`, `rowspan`, `valign`, `nowrap`; locked in `sanitizer_policy/attributes.txt`): column layout and spans come from inline CSS only | none yet | all | open |
| 14 | `ImageTransformer` and `AddLazyLoadingForBackgroundImageTransformer` match case-sensitively: `HTTPS://` images get no `loading="lazy"`, `BACKGROUND-IMAGE:url(…)` stays eager | none yet | all | open |

## Coverage: what the rules prove

Each display mechanism of the received-mail viewers is either proven by a
mutation (`mutation_proof_browser_test.dart` breaks it in the test and a rule
must turn a fixture red) or listed with the reason it has no proof.
Re-check this table when a transformer, the viewer CSS or a viewer script is
added.

| Mechanism | Proof (rule → first red fixture) |
|---|---|
| `BlockQuotedTransformer` | G-overflow → `real/eml_12` |
| `BlockCodeTransformer` + `pre { white-space: pre-wrap }` (each alone is masked by the other) | G-overflow → `layout_stress/wide_pre` |
| `ImageTransformer`, `AddLazyLoadingForBackgroundImageTransformer`, lazy background script | lazyImages → `expect_checks/lazy_images` |
| `NormalizeLineHeightInStyleTransformer` | G-line-height → `real/eml_27` |
| `ResponsiveTableCellTransformer` | G-overflow → `layout_stress/long_url_cell`, `real/eml_10` |
| `RemoveNegativeMarginFloatTransformer` | G-overflow → `real/eml_39` |
| Sanitizer losing content | G-preserve → `expect_checks/auto_scale_reflow_table` |
| Plain text: `SanitizeAutolinkHtmlTransformers` | G-preserve (links) → `edge/plain_text_table` |
| Plain text: `PersistPreformattedTextTransformer` | G-ascii-table → `edge/plain_text_markdown_table` |
| CSS: `.tmail-content` wrapping, `table { white-space }`, `@media` table width and link fill, `box-sizing`, default body font | G-overflow → `real/eml_20`, `eml_31`, `wide_table`, `eml_12`, `eml_38`, `eml_43` |
| Normalize image script | G-image-fit → `layout_stress/wide_image` |
| Mobile responsive script, reflow font floor | autoScale → `expect_checks/auto_scale_reflow_table` |
| Quote toggle (markup, script, collapsed style) | quoteToggle → `expect_checks/quote_toggle` |

No proof, verified:

- `RemoveScriptTransformer`: the sanitizer already drops `<script>`, `on*`
  handlers and `javascript:` links (checked with the transformer removed).
  `SanitizeHyperLinkTagInHtmlTransformer` and
  `SanitizePlainTextHtmlOutputTransformer` are link/security behaviour with no
  layout effect. All three have unit tests and HTML locks.
- `RemoveCollapsedSignatureButtonTransformer`: no visible effect. The composer
  flattens the signature before sending
  (`HtmlAnalyzer.removeCollapsedExpandedSignatureEffect`), and the sanitizer
  drops the editor's button markup.
- `table, td, th { word-break: normal }`: no effect, because the cell
  transformer's `overflow-wrap: anywhere` wins. Removing it changes nothing
  (bug 12).
- `body { overflow-x: hidden }` only clips what G-overflow already reports.
  `p { margin: 0 }`, the code-block colours and the font family are cosmetic;
  the HTML locks pin them.

Not covered by this harness (needs widget or device tests):

- Flutter side: height reporting (web `htmlHeight` messages, Android
  content-size script, `html, body { height: auto }`), scroll / wheel / touch
  listeners, link click / hover / tooltip, keyboard shortcuts, zoom lock.
- Engines and fonts: every run uses Chrome, not WKWebView or Android WebView,
  with CI fonts.
- Other pipelines (reply / forward, drafts, print, signatures, calendar).
