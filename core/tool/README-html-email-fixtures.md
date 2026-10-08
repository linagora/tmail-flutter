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
- Images (including `data:` images) become `https://fixture.invalid/{img|cid}/<W>x<H>`.
  CID and `data:` sizes are read from the image bytes. Remote sizes come from the `width`/`height` attributes,
  then the inline CSS, then the containing `td`/`table` width, then 600x300.
  The sidecar's `imageSizes` counts each source, so `container` and `default`
  mark sizes that are estimates.
- Every URL is replaced with a stable placeholder of the same length: absolute,
  protocol-relative (`//host`), relative (`/path?q`), `srcset`, CSS `url()`.
  `mailto:` keeps only a fake address (query dropped), `tel:` a fake number.
- Addresses, names and sender domains are replaced, same length. Names come
  from the From/To/Cc headers and from `Name <addr>` in the body (quoted reply
  headers); each name word of 3+ letters is replaced too, case-insensitively.
  They are replaced in text, comments and text attributes (`alt`, `title`...),
  never in tag names, attribute names, `class`, `id` or `style`.
- Tag and attribute names are kept exactly; only values are rewritten.
- The same EML always gives byte-identical output (any process, any hash seed).

## Review before committing

- The console report must show `LEFTOVER ... 0` for every row (hosts, emails,
  long numbers, phone numbers in the visible text). Otherwise run
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
