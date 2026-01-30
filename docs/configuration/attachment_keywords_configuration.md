## Attachment Keyword Detection — Configuration

The system warns users when email content implies an attachment (e.g. "please find attached") but no file is attached.

### Configuration file

`configurations/attachment_keywords.json` (must be declared in `pubspec.yaml` under `assets`):

```json
{
  "includeList": ["invoice", "estimate", "báo giá"],
  "excludeList": ["signature-logo", "no-reply", "icon-app"]
}
```

| Field | Purpose |
|-------|---------|
| `includeList` | Add custom keywords to the built-in multi-language dictionary (case-insensitive) |
| `excludeList` | Suppress false positives — tokens matched here are ignored even if they contain a keyword |

### How it works

1. On "Send", if the user already has an attachment, the check is skipped entirely.
2. Email HTML is converted to plain text (signatures, quotes, and HTML stripped).
3. `includeList` is merged with the built-in dictionary; a Unicode-aware Regex is built (cached).
4. Each match is validated against `excludeList` using full surrounding token context.
5. If keywords remain and no file is attached, a warning dialog is shown.

**Sync/Async:** Emails < 20,000 chars run synchronously; larger emails offload to a Dart Isolate via `compute()`.
**Cache:** Config and Regex pattern are cached in memory; both cleared on logout.
