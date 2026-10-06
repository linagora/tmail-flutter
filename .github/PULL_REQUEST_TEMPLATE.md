## Summary


## Test plan


## HTML display (if this PR changes email HTML transform, viewer, or a display bug)

- [ ] Display bug fix: offending email added under `core/test/fixtures/html_emails/` (anonymized)
- [ ] Reviewer approved anonymization:
      names/emails replaced; no tokens/session IDs in URLs; no private message content; markup kept; `source` in sidecar `.json`
- [ ] Regenerated `core/test/fixtures/html_emails/html_email_corpus.g.dart`
      (`cd core && fvm dart run tool/generate_html_email_corpus.dart`)
- [ ] Chrome layout + preservation tests run
