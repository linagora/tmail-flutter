# 0089. Fix Blank Plain-Text Email Caused by Backslash-Hex False-Positive in HTML Sanitizer

Date: 2026-05-15

## Status

Accepted

## Context

Plain-text emails containing `\XX` patterns (e.g. PHP namespace paths like `\Sabre\DAV\Exception\Forbidden`) were displayed completely blank after rendering. The issue occurred whenever at least one `\XX` token happened to consist of two valid hex digits.

## Root Cause

A four-level chain:

1. **Architecture mismatch** — `StandardizeHtmlSanitizingTransformers` (an HTML sanitizer) was incorrectly placed first in the `textPlain` pipeline. Plain text is not HTML.
2. **Overly broad regex** — `NodeSanitizer._isEncodedJs()` in `dart-neats/sanitize_html` uses `RegExp(r'\\[0-9a-f]{2}')` to detect unicode-escape obfuscation. This matches any single `\XX` pair, so `\DA` in `\Sabre\DAV` triggers it.
3. **Text node stripped** — `_shouldStripText()` calls `node.remove()` on match, deleting the entire text node.
4. **Blank email** — `body.innerHtml` becomes empty; the webview renders a blank screen.

## Decision

### Fix 1 — tmail-flutter: rebuild the plain-text pipeline

Remove `StandardizeHtmlSanitizingTransformers` and replace with a purpose-built three-layer pipeline:

| Layer | Transformer | Responsibility |
|-------|-------------|----------------|
| 1 | `SanitizeAutolinkHtmlTransformers` | HTML-escape all text via `htmlEscape.convert()` before any parsing. No user input can reach later layers as executable HTML. URLs are autolinked into `<a>` tags. |
| 2 | `SanitizePlainTextHtmlOutputTransformer` | Allows only `<a>` tags whose `href` passes `Uri.tryParse()` scheme validation (`http`, `https`, `mailto`) plus an attribute allowlist. All other elements are unwrapped; comments are removed. Text nodes are never inspected — Layer 1 already escaped them. |
| 3 | `PersistPreformattedTextTransformer` | Converts newlines to `<br>` and wraps in `<pre>`. |

Layer 2 validates `href` with `Uri.tryParse()` rather than a string-prefix check, so uppercase schemes (`HTTPS://`), empty hrefs, relative paths, and malformed URLs are handled correctly by the platform URI parser.

### Fix 2 — dart-neats: tighten `unicodeEscapeReg`

```dart
// Before — matches any single \XX pair
RegExp(r'\\[0-9a-f]{2}', caseSensitive: false)

// After — requires 3+ consecutive pairs
RegExp(r'(\\[0-9a-f]{2}){3,}', caseSensitive: false)
```

Any dangerous keyword obfuscated via hex escapes needs at least 3 pairs (e.g. `\73\72\63` = `"src"`). A single pair like `\DA` is not executable and must not cause stripping.

## Consequences

- Plain-text emails with `\XX` patterns (PHP/Go namespaces, file paths, regex literals) render correctly.
- XSS is blocked at two independent layers (escape + tag allowlist) without relying on content heuristics.
- `StandardizeHtmlSanitizingTransformers` is removed from the plain-text path; it remains in the HTML path where it belongs.
- The tmail-flutter fix is sufficient to resolve the bug independently. The dart-neats fix requires publishing `fix/tighten-unicode-escape-regex` and updating `pubspec.yaml`.
