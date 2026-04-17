# 80. Patrol Web Integration Test — Setup & Execution

Date: 2026-04-15

## Status

Accepted

## Related ADRs

- [ADR-0053](./0053-patrol-integration-test.md) — Patrol for mobile integration testing (foundation)
- [ADR-0081](./0081-patrol-web-test-architecture.md) — Cross-platform test architecture
- [ADR-0082](./0082-patrol-web-test-migration-guide.md) — Migration guide & implementation example
- [ADR-0083](./0083-patrol-web-test-migration-plan.md) — PR-by-PR migration plan

## Context

[ADR-0053](./0053-patrol-integration-test.md) established Patrol for mobile (Android/iOS) integration testing. As Twake Mail is also deployed as a web app, the same level of E2E coverage is needed on the browser. Patrol 4.x added Chrome support via `--device=chrome`, making it feasible to extend the existing setup without introducing a second testing framework.

## Decision

Use Patrol with Chrome as the target device for web integration testing, sharing the same backend Docker infrastructure used for mobile tests.

### Prerequisites

- Flutter 3.38.9
- Patrol CLI 4.3.1: `dart pub global activate patrol_cli 4.3.1`
- `patrol` package **4.5.0** (and `patrol_finders 3.x`, `patrol_log 0.8.x`) — requires upgrading from the 3.x currently in `pubspec.yaml`
- Docker Desktop (running)
- `openssl` installed (used to generate JWT keys for the backend)

> Unlike mobile tests, web tests do **not** require `ngrok` or `jq`. The app runs at `localhost` and Chrome connects to it directly — no traffic forwarding needed.

### Environment Variables

All tests receive configuration via `--dart-define`. Store values in an env file and source it in the run scripts — this keeps credentials out of command-line history and git history (add the file to `.gitignore`):

```bash
# integration_test/test_config.env
BASIC_AUTH_URL=http://localhost/
USERNAME=test_user
PASSWORD=test_password
BASIC_AUTH_EMAIL=test@example.com
ADDITIONAL_MAIL_RECIPIENT=recipient@example.com
```

The run scripts source this file and forward each value:

```bash
source integration_test/test_config.env
patrol test \
  --dart-define=BASIC_AUTH_URL=$BASIC_AUTH_URL \
  --dart-define=USERNAME=$USERNAME \
  --dart-define=PASSWORD=$PASSWORD \
  --dart-define=BASIC_AUTH_EMAIL=$BASIC_AUTH_EMAIL \
  --dart-define=ADDITIONAL_MAIL_RECIPIENT=$ADDITIONAL_MAIL_RECIPIENT \
  ...
```

| Variable | Description |
|----------|-------------|
| `BASIC_AUTH_URL` | App server URL (e.g. `http://localhost/`) |
| `USERNAME` | Test account username |
| `PASSWORD` | Test account password |
| `BASIC_AUTH_EMAIL` | Test account email address |
| `ADDITIONAL_MAIL_RECIPIENT` | Secondary email for multi-recipient tests |

> `--dart-define-from-file` only accepts JSON, not `.env` format, so sourcing in the script is the correct approach.

### Running Locally (with visible browser)

```bash
./scripts/patrol-web-local-integration-test-with-docker.sh
```

This starts the Docker backend, then runs patrol with Chrome visible. Useful during development.

To run a single test file, edit the script and replace `patrol test -v` with:

```bash
patrol test -v -t integration_test/tests/composer/send_email_test.dart
```

> After migrating to the architecture defined in [ADR-0081](./0081-patrol-web-test-architecture.md), test files no longer have a `web_` prefix — one file covers all platforms.

### Running in CI (headless)

```bash
./scripts/patrol-web-integration-test-with-docker.sh
```

Adds `--web-headless=true` — no display required. The GitHub Actions workflow (`.github/workflows/patrol-web-integration-test.yaml`) runs this script on pull requests.

### CI Orchestration — Running the Full Project

Mobile and web test suites run as **separate parallel jobs** in CI. Each job targets its own platform:

```text
PR opened / push
│
├── job: patrol-mobile-integration-test   (ubuntu-latest + Android emulator)
│     patrol test --device=android
│
└── job: patrol-web-integration-test      (ubuntu-latest + Chrome via Patrol)
      ./scripts/patrol-web-integration-test-with-docker.sh
      # patrol test --device=chrome --web-headless=true
```

The two jobs are independent — they share no state and can run concurrently. A PR is gated on **both** jobs passing.

Platform filtering is handled automatically by `runPatrolTest()` (see [ADR-0082](./0082-patrol-web-test-migration-guide.md)). Tests that do not apply to the current platform skip themselves — no `--exclude-tags` flag needed in either job.

### Viewing Results

- **Terminal:** Patrol prints pass/fail per test with full stack traces on failure.
- **GitHub Actions:** Results appear in the workflow run summary under the "Test" step. Each platform job has its own step, making it easy to identify which platform a failure comes from.

## Consequences

- Web and mobile tests share the same test files; platform-only tests skip themselves in `runPatrolTest()` — no manual tagging required.
- The same Docker JMAP backend serves both platforms — no additional infrastructure needed.
- Data isolation limitations from [ADR-0053](./0053-patrol-integration-test.md) still apply: backend state is shared across all tests in a single run.
- Patrol automatically installs and manages Chromium — no manual Chrome installation is needed on local machines or CI runners.
