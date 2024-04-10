# 44. Memory leak at current state

Date: 2024-04-09

## Status

- Issues: 
  - [Memory footprint #2533](https://github.com/linagora/tmail-flutter/issues/2533)
- PRs:
  - [TF-2533: [PART-1] Clean up email detail content #2759](https://github.com/linagora/tmail-flutter/pull/2759)
  - [TF-2533 [PART-2] Remove email detail iframe dependencies #2760](https://github.com/linagora/tmail-flutter/pull/2760)
  - [TF-2533 [PART-3] Composer memory leak #2783](https://github.com/linagora/tmail-flutter/pull/2783)
  - [TF-2533 [Part-4] File picker memory leak #2788](https://github.com/linagora/tmail-flutter/pull/2788)

## Context

- Through 4 PR, the current state of memory leak issue in TMail is as follow:
  - Composer:
    - Web: Resolved
    - Mobile: Resolved
  - Email content view:
    - Web: Resolved
    - Mobile: Remained until [InAppWebView memory leak on Android #1023](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1023) is fixed
  - Identity create/edit:
    - Web: Resolved
    - Mobile: No problem detected, nothing changed.

## Decision

- This work will be on hold until significant memory leaks are reported (E.g. App consumes twice the regular amount of memory within one day usage)
  
## Consequences

- Most noticed memory leak problems on TMail are resolved.
