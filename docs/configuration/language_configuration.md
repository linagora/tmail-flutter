## Configuration Allowed Languages

### Context
- By default, users can pick any language Twake Mail ships with
  (fr, en, vi, ru, ar, it, de, mn, pt).
- An operator can limit the languages offered by the web app to a chosen set. This is optional.

### How to config
In [env.file]:
- To offer only Mongolian and English:
```ALLOWED_LANGUAGES=mn,en```
- To offer every language:
```ALLOWED_LANGUAGES=```
    or remove the key.

Rules:
- Comma-separated language codes. Spaces, case and quotes are ignored
  (`ALLOWED_LANGUAGES="MN, en"` works).
- A region is ignored: `pt`, `pt-BR` and `pt_BR` all mean Brazilian Portuguese.
- Unknown codes are ignored. If no code is known, every language is offered.
- The language picker lists the languages in the configured order.
- When the language from the server settings, the saved choice or the
  device/browser is not allowed, the app uses English if it is allowed,
  otherwise the first configured language. This also applies to the login screen.
- The server language setting is never overwritten because of this option.
- Set the key in `env.file` only, not in `configurations/env.fcm`.

### Platforms
- Web only. `env.file` is served with the app, so the option can be changed per
  deployment without a rebuild. It also applies to the web app opened in a phone
  or tablet browser.
- The Android and iOS apps ignore this key and always offer every language.
