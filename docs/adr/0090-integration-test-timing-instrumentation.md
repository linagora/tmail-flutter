# ADR-0090: Integration Test Timing Instrumentation

**Status:** Implemented | **Date:** 2026-05-18

## Context

Patrol integration tests had no per-phase timing visibility. Impossible to tell whether slowness came from Docker startup, app launch, login, test logic, or backend reset. Patrol 3.19.0 has no native timing hooks.

## Decision

Instrument all layers — Dart test infra, backend reset server, shell bootstrap — to emit structured timing tags to stdout. A Python report generator parses these tags and produces a self-contained HTML report.

## Architecture

```
Shell script phases          Dart test phases             Backend reset phases
─────────────────────        ──────────────────           ────────────────────
docker_cleanup               app_launch                   delete_domain_data
jwt_keygen                   login                        delete_user_vault
docker_startup               test_logic                   provisioning
initial_provisioning           └─ timedStep("...")
reset_server_start           backend_reset (teardown)
patrol_build      ← "Executing tests of" in patrol stdout marks boundary
patrol_run
```

Dart `[TIMING_REPORT]` tags POST to reset server `/timing`; server emits them to its stdout (captured in `RESET_SERVER_LOG`). Shell phases flow through `2>&1 | tee` capture.

## Output Tags

| Tag | Source | Content |
|-----|--------|---------|
| `[TIMING_REPORT]` | Python reset server (POST `/timing` from Dart) | Per-test JSON: phases + steps + total_ms |
| `[RESET_TIMING_REPORT]` | Python reset server | Per-reset JSON: sub-phase ms |
| `[SCRIPT_TIMING]` | Shell script | Per-phase ms (real-time) |
| `[SCRIPT_TIMING_DETAIL]` | Shell script cleanup trap | Same phases, emitted in summary |
| `[SCRIPT_TIMING_SUMMARY]` | Shell script | Total script ms |

## Implementation

**`TestTimer` singleton** (`integration_test/utils/test_timer.dart`) — wraps async ops with `Stopwatch`. API: `startTest(name)`, `timedPhase(name, fn)`, `timedStep(name, fn)`, `printReport()` (POSTs JSON to `/timing`). Four standard phases: `app_launch`, `login`, `test_logic`, `backend_reset`.

**Dart instrumentation:**
- `test_base.dart` — `setupTest()` in `timedPhase('app_launch')`, `_tearDown()` wraps reset in `timedPhase('backend_reset')` then calls `printReport()` (must be after `patrolTearDown` so reset time is captured)
- `base_test_scenario.dart` — login in `timedPhase('login')`, `runTestLogic()` in `timedPhase('test_logic')`
- `base_scenario.dart` — `timedStep` delegate so concrete scenarios can time individual steps without importing `TestTimer` directly

**Backend reset server** — `reset_backend()` measures `delete_domain_data_ms`, `delete_user_vault_ms`, `provisioning_ms`; emits `[RESET_TIMING_REPORT]`. Accepts POST `/timing`, emits `[TIMING_REPORT]`.

**Shell script** — helpers `_now_ms()` (macOS/Linux portable; python3 fallback), `_record_phase name start`. Wraps each major section. `patrol test` piped through `while read` loop detecting `"Executing tests of"` to split `patrol_build` / `patrol_run` phases (falls back to single `test_run` on build failure). `cleanup()` trap emits `[SCRIPT_TIMING_SUMMARY]` + `[SCRIPT_TIMING_DETAIL]`.

**HTML report** (`scripts/patrol-timing-report.py`) — parses all tag types. Generates: stacked Plotly bar chart per test, shell setup table, per-test summary with p75/p95 color coding, expandable step rows, reset breakdown table. Deps: `pip install plotly jinja2`.

```bash
bash scripts/patrol-local-integration-test-with-docker.sh
# Log:    integration_test/report/patrol-test-YYYYMMDD-HHMMSS.log
# Report: integration_test/report/patrol-timing-report.html  (auto-opened on macOS)
```

## Consequences

**Benefits:** per-phase bottleneck visibility; `backend_reset` (30–90s) now measurable; step granularity opt-in; HTML works as CI artifact.

**Tradeoffs:** `timedStep` wrapping is manual per scenario; Plotly CDN requires internet (set `include_plotlyjs=True` for air-gapped CI); `_now_ms` python3 fallback adds ~50ms on macOS.

## Files Changed

| File | Change |
|------|--------|
| `integration_test/utils/test_timer.dart` | NEW — singleton timing collector |
| `integration_test/base/test_base.dart` | app_launch + backend_reset phases |
| `integration_test/base/base_test_scenario.dart` | login + test_logic phases |
| `integration_test/base/base_scenario.dart` | `timedStep` delegate |
| `scripts/backend-reset-server.py` | Timed sub-phases + `/timing` endpoint |
| `scripts/patrol-local-integration-test-with-docker.sh` | Helpers + patrol_build/patrol_run split |
| `scripts/patrol-timing-report.py` | NEW — HTML report generator |
