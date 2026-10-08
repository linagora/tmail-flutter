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

## Pending display bugs (real emails, red on purpose)

Real fixtures are committed even when they break a display rule (decision:
the email documents the bug; its fix PR turns it green). Viewer/width:
`n` native, `w` web, `i` iOS previewer. Status 2026-10-08.

| Finding | Fixtures (`real/eml_*`) | Where |
|---|---|---|
| Native responsive script leaves the email overflowing | 1, 8 (296), 12, 20 | n296–n744 |
| iOS previewer has no image normalize / responsive script: wide content overflows | 1, 2, 6, 7, 8, 9, 11, 12, 13, 16, 19, 20, 23, 29, 31, 32, 34, 35, 36, 38, 39, 40, 43 | i296–i390 |
| Web does not fit wide content (no responsive script; the 600px media query only resizes tables) | 1, 2, 6, 8, 12, 20, 29, 34, 35, 36, 38, 40, 43 | w524–w1000 |
| Image wider than the pane | 16, 23, 40 (iOS); 2, 34, 40 (web 760) | i296–i390, w760 |
| Image squashed: fixed `height` + `max-width:100%` from the normalize script (width shrinks, height stays) | 6, 13, 15, 31, 36 (w524) | n, w (15 also i) |
| Quoted text below 13px at ≤ 480px: the rule sets 13px on the `blockquote` only, inner inline sizes win | 6, 12, 43 | n296–n390 |
| Expanded quote overflows the pane (20: about 30 nested `blockquote` levels) | 12 (296–390), 20 | n296–n744 |
| Image never shown (0×0): sender lazy-loading with only `data-src` | 28; also 13, 36 at some widths | n, w |
| Body taller than the native viewer cap (`ConstantsUI.htmlContentMaxHeight`) | 20 | n744, w760 |
| Plain-text ASCII table in a `white-space: pre` block overflows | 35 | i, w |

Synthetic fixtures with recorded findings: `layout_stress/wide_image`,
`layout_stress/wide_table`, `newsletter_builders/mailchimp`,
`expect_checks/auto_scale_*`, `expect_checks/quote_toggle_wide` (iOS and web
do not fit fixed-width content).
