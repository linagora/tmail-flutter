# Memory leak check

Profile-mode Patrol tests that compare memory before and after a heavy flow.
Runs on web and Android.
Tag: `memory`. Excluded from the normal Patrol scripts (`--exclude-tags=memory`).

## Flows

- `open_heavy_inline_email`: open a mail with a 5 MB inline image, then leave it.
- `two_composers_heavy_send`: compose and send mails with a heavy inline image and attachment.
- `identity_heavy_inline`: create and delete an identity with a heavy signature image.

Each flow runs twice.
The first run warms caches, the second is measured.
Memory is sampled before and after the second run.

## Limits

- The test cannot see inside the sandboxed mail viewer, so it does not check that the inline image finished loading.
- Composers run one after the other, concurrent composers are not covered.

## Rules

Limits live in `integration_test/memory/memory_rules.json`.

| Rule | Checks |
| --- | --- |
| R1 | Classes listed in `mustReturnToBaseline` do not grow |
| R2 | Buffer growth stays under `maxBufferGrowthBytes` |
| R3 | Total heap growth stays under `maxTotalGrowthBytes` |
| R4 | No tmail class grows more than `maxTmailClassGrowthBytes` |
| R5 | Android RSS growth stays under `maxRssGrowthBytes` |

Web totals exclude the CanvasKit WebAssembly heap.

## Run locally

- Needs Docker (local JMAP backend) and `bash scripts/prebuild.sh` done once.
- Web: `bash scripts/memory-leak-check.sh web`
- Android: boot an emulator (`emulator-5554`), then `bash scripts/memory-leak-check.sh android` (needs Bash 4+; on macOS install it with `brew install bash`)
- Output goes to `$CI_LOGS` (default `./ci-logs`), report is printed at the end.

Useful variables:

- `CI_LOGS`: output folder.
- `MEMORY_REPORT_ONLY=1`: print the report, always exit 0 (calibration).
- `MEMORY_PATROL_ARGS`: extra Patrol args, for example `--show-flutter-logs --target integration_test/tests/memory/<test>.dart`.

Report unit tests: `python3 -m unittest discover -s scripts -p 'test_memory_leak_report.py'`.

## CI

- Workflow: `.github/workflows/memory-leak-check.yaml`.
- Runs on release tags (called by `image-sentry.yaml`), on PRs touching the check, and on PRs labelled `memory-check`.
- The report is always published, even when a rule fails.

## Add a case

- Add a scenario in `integration_test/scenarios/memory/` extending `MemoryLeakScenario`.
- Implement `caseId` and `runCycle` (and `prepare` if the flow starts on another screen).
- Add a test in `integration_test/tests/memory/` with tags `web`, `android`, `memory` and a timeout.
- Add the case to `memory_rules.json`, with `mustReturnToBaseline` for controllers that must be disposed.
- Run it with `MEMORY_REPORT_ONLY=1` several times, then set limits above the observed maximum.
