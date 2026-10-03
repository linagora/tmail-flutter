Closes #4946

## Problem
The unsubscribe confirmation dialog was put together from three pieces: the localized prefix, the sender name and a hard-coded `' ?'`. As a result, every language showed "… from **Emma** ?".

## Fix
- `unsubscribeMailDialogMessage` now takes a `{senderName}` placeholder, so each translation controls word order and punctuation (e.g. English `from {senderName}?`, French `de {senderName} ?`).
- `EmailActionReactor` splits the localized text around the sender name so the name is still shown in bold.
- Existing translations were migrated to the placeholder form (`de`, `fr`, `ga`, `id`, `mn`, `pt_BR`, `ru`, `ta`, `uk`, `vi`, `zh_Hans`, plus `intl_messages.arb`). For `zh_Hans` and `mn`, the sentence was reworded so the sender name sits in a natural position. Native speakers may want to review these on Weblate.

## Checks
No Flutter SDK was available in the environment, so I could not run the build, `prebuild.sh` (arb regeneration) or the tests. Please let CI validate.

---
*Generated automatically*

🤖 Generated with [Claude Code](https://claude.com/claude-code)
