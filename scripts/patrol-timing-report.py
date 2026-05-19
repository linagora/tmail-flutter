#!/usr/bin/env python3
"""
Parse patrol integration test log output and generate a self-contained HTML
timing report.

Usage:
  # From a saved log file:
  python3 scripts/patrol-timing-report.py /tmp/test_run.log /tmp/report.html

  # From stdin (pipe directly from patrol):
  bash scripts/patrol-local-integration-test-with-docker.sh 2>&1 \
    | tee /tmp/test_run.log \
    | python3 scripts/patrol-timing-report.py - /tmp/report.html

Dependencies:
  pip install plotly jinja2
"""

import json
import re
import sys
from pathlib import Path
from dataclasses import dataclass, field


# ── Data models ───────────────────────────────────────────────────────────────

@dataclass
class TestRecord:
    name: str
    status: str
    phases: dict
    steps: list
    total_ms: int


@dataclass
class ResetRecord:
    delete_domain_data_ms: int
    delete_user_vault_ms: int
    restore_backup_ms: int
    total_ms: int


@dataclass
class EventRecord:
    event: str
    ts_ms: int


@dataclass
class ParsedLog:
    script_phases: dict = field(default_factory=dict)
    script_abs_ts: dict = field(default_factory=dict)
    script_total_ms: int = 0
    tests: list = field(default_factory=list)
    resets: list = field(default_factory=list)
    events: list = field(default_factory=list)


# ── Parsers ───────────────────────────────────────────────────────────────────

_RE_TIMING_REPORT  = re.compile(r'\[TIMING_REPORT\] (.+)')
_RE_RESET_REPORT   = re.compile(r'\[RESET_TIMING_REPORT\] (.+)')
# Matches both [SCRIPT_TIMING] (real-time) and [SCRIPT_TIMING_DETAIL] (cleanup summary)
_RE_SCRIPT_TIMING  = re.compile(r'\[SCRIPT_TIMING(?:_DETAIL)?\] (\w+)=(\d+)ms')
_RE_SCRIPT_SUMMARY = re.compile(r'\[SCRIPT_TIMING_SUMMARY\] total=(\d+)ms')
# Absolute wall-clock timestamps (ms since epoch) from the shell script
_RE_ABS_TS         = re.compile(r'\[SCRIPT_ABS_TS(?:_DETAIL)?\] (\w+)=(\d+)')
# Named events emitted by device via /event endpoint, timestamped server-side
_RE_EVENT          = re.compile(r'\[EVENT\] (.+)')
# Web test results emitted by patrol Playwright runner: "✅ Description (/path.dart) (Xs)"
# Not indented (step-level ✅ lines are indented and lack the dart path + duration suffix)
_RE_WEB_RESULT     = re.compile(r'^([✅❌])\s+(.+?)\s+\(/[^)]+\.dart\)\s+\((\d+)s\)\s*$')


def _fill_phases_from_steps(record: TestRecord) -> None:
    """For any phase absent or zero in phases dict, compute it by summing the steps."""
    if not record.steps:
        return
    phase_sums: dict = {}
    for step in record.steps:
        ph = step_phase(step['name'])
        phase_sums[ph] = phase_sums.get(ph, 0) + step['ms']
    for ph, total in phase_sums.items():
        if record.phases.get(ph, 0) == 0:
            record.phases[ph] = total


def _inject_bulk_step(record: TestRecord) -> None:
    """For each phase that has time in phases but no corresponding steps, add a synthetic bulk step."""
    covered_phases = {step_phase(s['name']) for s in record.steps}
    for ph in ('test_logic', 'login', 'app_launch'):
        ms = record.phases.get(ph, 0)
        if ms > 0 and ph not in covered_phases:
            step_name = f'{ph}_bulk'
            record.steps.append({'name': step_name, 'ms': ms})


def parse_log(lines: list) -> ParsedLog:
    result = ParsedLog()
    for line in lines:
        if m := _RE_TIMING_REPORT.search(line):
            d = json.loads(m.group(1))
            rec = TestRecord(
                name=d['test'],
                status=d.get('status', 'unknown'),
                phases=d.get('phases', {}),
                steps=d.get('steps', []),
                total_ms=d['total_ms'],
            )
            _fill_phases_from_steps(rec)
            _inject_bulk_step(rec)
            result.tests.append(rec)
        elif m := _RE_RESET_REPORT.search(line):
            d = json.loads(m.group(1))
            result.resets.append(ResetRecord(
                delete_domain_data_ms=d.get('delete_domain_data_ms', 0),
                delete_user_vault_ms=d.get('delete_user_vault_ms', 0),
                restore_backup_ms=d.get('restore_backup_ms', 0),
                total_ms=d.get('total_ms', 0),
            ))
        elif m := _RE_SCRIPT_TIMING.search(line):
            result.script_phases[m.group(1)] = int(m.group(2))
        elif m := _RE_SCRIPT_SUMMARY.search(line):
            result.script_total_ms = int(m.group(1))
        elif m := _RE_ABS_TS.search(line):
            result.script_abs_ts[m.group(1)] = int(m.group(2))
        elif m := _RE_EVENT.search(line):
            d = json.loads(m.group(1))
            result.events.append(EventRecord(
                event=d.get('event', 'unknown'),
                ts_ms=d.get('ts_ms', 0),
            ))
        elif m := _RE_WEB_RESULT.match(line.rstrip()):
            status = 'passed' if m.group(1) == '✅' else 'failed'
            name = m.group(2)
            total_ms = int(m.group(3)) * 1000
            result.tests.append(TestRecord(
                name=name,
                status=status,
                phases={'test_logic': total_ms},
                steps=[],
                total_ms=total_ms,
            ))
    return result


# ── Phase descriptions ────────────────────────────────────────────────────────

PHASE_DESCRIPTIONS = {
    'docker_cleanup':       'Stop and remove existing containers',
    'jwt_keygen':           'Generate JWT signing keys',
    'docker_startup':       'Start backend Docker services',
    'initial_provisioning': 'Create initial test users and data',
    'reset_server_start':   'Start HTTP reset server',
    'patrol_build':         'Compile Flutter app and test bundle',
    'patrol_run':           'Execute patrol tests on device',
    'docker_teardown':      'Docker Compose down after all tests',
}

# Steps whose names start with these prefixes belong to the login phase.
_LOGIN_STEP_PREFIXES = ('login_',)
# Steps whose names start with these prefixes belong to the app_launch phase.
_APP_LAUNCH_STEP_PREFIXES = ('env_load', 'app_start')


# ── Formatters ────────────────────────────────────────────────────────────────

def ms_to_s(ms: int) -> str:
    return f"{ms / 1000:.2f}s"


def highlight_class(ms: int, p75: float, p95: float) -> str:
    if ms >= p95:
        return 'slow'
    if ms >= p75:
        return 'medium'
    return 'fast'


def pct(part: int, total: int) -> str:
    if total == 0:
        return '0%'
    return f'{part / total * 100:.1f}%'


def step_phase(name: str) -> str:
    if name == 'login_bulk':
        return 'login'
    if name == 'app_launch_bulk':
        return 'app_launch'
    if name == 'test_logic_bulk':
        return 'test_logic'
    if any(name.startswith(p) for p in _LOGIN_STEP_PREFIXES):
        return 'login'
    if any(name.startswith(p) for p in _APP_LAUNCH_STEP_PREFIXES):
        return 'app_launch'
    return 'test_logic'


def compute_overhead_rows(tests: list) -> list:
    rows = []
    for t in tests:
        overhead = (
            t.phases.get('app_launch', 0)
            + t.phases.get('login', 0)
            + t.phases.get('backend_reset', 0)
        )
        logic = t.phases.get('test_logic', 0)
        total = t.total_ms or 1
        rows.append({
            'name': t.name,
            'status': t.status,
            'overhead_ms': overhead,
            'logic_ms': logic,
            'total_ms': total,
            'overhead_pct': pct(overhead, total),
            'logic_pct': pct(logic, total),
        })
    return rows


def compute_patrol_framework_overhead(script_phases: dict, tests: list):
    patrol_run_ms = script_phases.get('patrol_run', 0)
    if not patrol_run_ms or not tests:
        return None
    sum_test_ms = sum(t.total_ms for t in tests)
    unaccounted = patrol_run_ms - sum_test_ms
    return {
        'patrol_run_ms': patrol_run_ms,
        'sum_test_ms': sum_test_ms,
        'unaccounted_ms': unaccounted,
        'unaccounted_pct': pct(unaccounted, patrol_run_ms),
    }


def compute_inter_test_timeline(log):
    """
    Pair harness_setup / test_body_start / harness_teardown_end events with
    TIMING_REPORTs to reconstruct the full patrol_run breakdown:

      - pre_first_test:    patrol_run_start → first harness_setup
                           (APK install, Dart VM boot, Flutter bootstrap)
      - setUp_to_test:     harness_setup → test_body_start
                           (patrol internal: setUp callback → test body hand-off)
      - test_execution:    TIMING_REPORT total (startTest → printReport stop)
      - post_test_http:    TIMING_REPORT end → harness_teardown_end
                           (/timing + /event HTTP round-trips)
      - inter_test_gap:    harness_teardown_end[i] → harness_setup[i+1]
                           (patrol app restart between tests)
      - post_last_test:    last harness_teardown_end → patrol_run_end
                           (patrol CLI result printing + process exit)

    All timestamps are server-side ms-since-epoch; host and emulator share the same
    wall clock for local Docker runs. patrol_run_start/end come from the shell script.
    test_body_start events are optional — falls back to merged within_test_gap if absent.
    """
    setups      = [e for e in log.events if e.event == 'harness_setup']
    teardowns   = [e for e in log.events if e.event == 'harness_teardown_end']
    body_starts = [e for e in log.events if e.event == 'test_body_start']

    if not setups or not teardowns:
        return None

    n = min(len(setups), len(teardowns), len(log.tests))
    patrol_run_start = log.script_abs_ts.get('patrol_run_start')
    patrol_run_end   = log.script_abs_ts.get('patrol_run_end')
    has_body_start   = len(body_starts) >= n

    rows = []

    # Pre-first-test: patrol_run_start → first harness_setup
    if patrol_run_start and setups:
        rows.append({
            'label': 'Pre-first-test (patrol init + device startup)',
            'phase': 'patrol_framework',
            'ms': setups[0].ts_ms - patrol_run_start,
            'detail': 'APK install, Dart VM boot, Flutter bootstrap — before patrolSetUp fires',
        })

    for i in range(n):
        setup_ts    = setups[i].ts_ms
        teardown_ts = teardowns[i].ts_ms
        test_name   = log.tests[i].name if i < len(log.tests) else f'test {i+1}'
        total_ms    = log.tests[i].total_ms if i < len(log.tests) else 0
        server_duration = teardown_ts - setup_ts

        if has_body_start:
            body_start_ts  = body_starts[i].ts_ms
            # patrol overhead: patrolSetUp completes → test body first line
            setup_to_test  = body_start_ts - setup_ts
            # HTTP overhead: _totalWatch.stop() → /timing POST → /event POST → server timestamps teardown_end
            # total_ms is measured from startTest() which runs just after postEvent('test_body_start') returns,
            # so post_test_http = server_duration - setup_to_test - total_ms
            post_test_http = server_duration - setup_to_test - total_ms

            rows.append({
                'label': f'Test {i+1}: {test_name} — setUp→test delay',
                'phase': 'patrol_framework',
                'ms': setup_to_test,
                'detail': 'Patrol internal: patrolSetUp done → test body start (scheduling overhead)',
            })
            rows.append({
                'label': f'Test {i+1}: {test_name}',
                'phase': 'test_execution',
                'ms': total_ms,
                'server_ms': server_duration,
                'within_gap_ms': None,
                'detail': f'Measured by TIMING_REPORT; server window {ms_to_s(server_duration)}',
            })
            rows.append({
                'label': f'Test {i+1}: {test_name} — post-test HTTP',
                'phase': 'patrol_framework',
                'ms': max(0, post_test_http),
                'detail': 'HTTP: /timing POST + /event POST round-trips before teardown_end',
            })
        else:
            # Fallback: merged within-test gap (pre test_body_start instrumentation)
            within_test_gap = server_duration - total_ms
            rows.append({
                'label': f'Test {i+1}: {test_name}',
                'phase': 'test_execution',
                'ms': total_ms,
                'server_ms': server_duration,
                'within_gap_ms': within_test_gap,
                'detail': f'Measured by TIMING_REPORT; server sees {ms_to_s(server_duration)}',
            })

        # Inter-test gap: teardown_end[i] → setup[i+1]
        if i + 1 < len(setups):
            gap = setups[i + 1].ts_ms - teardowns[i].ts_ms
            rows.append({
                'label': f'Inter-test gap ({i+1}→{i+2})',
                'phase': 'patrol_framework',
                'ms': gap,
                'detail': 'Patrol app restart / test runner scheduling between tests',
            })

    # Post-last-test: last harness_teardown_end → patrol_run_end
    if patrol_run_end and teardowns:
        rows.append({
            'label': 'Post-last-test (patrol teardown)',
            'phase': 'patrol_framework',
            'ms': patrol_run_end - teardowns[-1].ts_ms,
            'detail': 'Patrol CLI result printing + process exit',
        })

    return rows if rows else None


def compute_reset_network_rows(tests: list, resets: list) -> list:
    rows = []
    for i, r in enumerate(resets):
        dart_ms = tests[i].phases.get('backend_reset', 0) if i < len(tests) else 0
        server_ms = r.total_ms
        overhead_ms = dart_ms - server_ms
        rows.append({
            'test_name': tests[i].name if i < len(tests) else '—',
            'dart_ms': dart_ms,
            'server_ms': server_ms,
            'overhead_ms': overhead_ms,
            'overhead_pct': pct(overhead_ms, dart_ms) if dart_ms else '0%',
            'restore_backup_ms': r.restore_backup_ms,
            'restore_backup_pct': pct(r.restore_backup_ms, server_ms) if server_ms else '0%',
        })
    return rows


# ── Chart generation ──────────────────────────────────────────────────────────

def generate_plotly_stacked_bar(tests: list) -> str:
    try:
        import plotly.graph_objects as go
    except ImportError:
        return '<p style="color:#888">Install plotly for charts: <code>pip install plotly</code></p>'

    phase_keys = ['app_launch', 'login', 'test_logic', 'backend_reset']
    colors = {
        'app_launch': '#4e79a7',
        'login': '#f28e2b',
        'test_logic': '#59a14f',
        'backend_reset': '#e15759',
    }

    import textwrap
    wrapped_names = ['<br>'.join(textwrap.wrap(t.name, width=30)) for t in tests]
    traces = []
    for key in phase_keys:
        values = [t.phases.get(key, 0) / 1000 for t in tests]
        traces.append(go.Bar(
            name=key.replace('_', ' ').title(),
            x=wrapped_names,
            y=values,
            marker_color=colors[key],
        ))

    fig = go.Figure(data=traces)
    fig.update_layout(
        barmode='stack',
        title='Test Duration by Phase (seconds)',
        xaxis_tickangle=0,
        yaxis_title='Duration (s)',
        legend_title='Phase',
        height=500,
    )
    # Use 'cdn' for smaller output; change to True for fully offline (~3MB)
    return fig.to_html(full_html=False, include_plotlyjs='cdn')


# ── HTML generation ───────────────────────────────────────────────────────────

_TEMPLATE = '''\
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Patrol Timing Report</title>
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
         margin: 2rem; background: #fafafa; color: #222; }
  h1 { color: #333; }
  h2 { color: #555; border-bottom: 1px solid #ddd; padding-bottom: .3rem; }
  table { border-collapse: collapse; width: 100%; margin-bottom: 2rem; font-size: .9rem; }
  th { background: #4e79a7; color: #fff; padding: .5rem .8rem; text-align: left; }
  td { padding: .45rem .8rem; border-bottom: 1px solid #eee; }
  tr:hover td { background: #f0f4ff; }
  .fast   { color: #2a9d41; font-weight: 600; }
  .medium { color: #e07b00; font-weight: 600; }
  .slow   { color: #d32f2f; font-weight: 700; }
  .passed { color: #2a9d41; font-weight: 600; }
  .failed { color: #d32f2f; font-weight: 700; }
  .unknown { color: #888; }
  .warn   { background: #fff8e1; border-left: 3px solid #e07b00; padding: .4rem .8rem;
             font-size: .85rem; margin-bottom: 1rem; }
  .info   { background: #e8f4fd; border-left: 3px solid #4e79a7; padding: .4rem .8rem;
             font-size: .85rem; margin-bottom: 1rem; }
  .gap-tag { display: inline-block; background: #fce4ec; color: #c62828; border-radius: 3px;
              font-size: .75rem; padding: .1rem .4rem; margin-right: .3rem; font-weight: 600; }
  details summary { cursor: pointer; color: #4e79a7; }
  .chart { margin-bottom: 2rem; }
  .meta  { font-size: .8rem; color: #888; margin-bottom: 2rem; }
  .step-login    { color: #f28e2b; }
  .step-launch   { color: #4e79a7; }
  .step-logic    { color: #59a14f; }
  .bar-wrap { background: #e0e0e0; border-radius: 3px; height: 12px; width: 120px; display: inline-block; vertical-align: middle; }
  .bar-fill { height: 12px; border-radius: 3px; display: block; }
</style>
</head>
<body>
<h1>Patrol Integration Test — Timing Report</h1>
<p class="meta">{{ n_tests }} tests | {{ n_resets }} resets{% if n_passed is defined %} | <span class="passed">{{ n_passed }} passed</span>{% if n_failed %} / <span class="failed">{{ n_failed }} failed</span>{% endif %}{% endif %}</p>

{% if script_phases %}
<h2>Test Suite Timing Breakdown</h2>
<table>
  <tr><th>Phase</th><th>Description</th><th>Duration</th></tr>
  {% for name, ms in script_phases.items() %}
  <tr><td>{{ name }}</td><td style="color:#555">{{ phase_desc.get(name, '') }}</td><td>{{ ms_to_s(ms) }}</td></tr>
  {% endfor %}
  <tr><td><strong>Total script</strong></td><td></td>
      <td><strong>{{ ms_to_s(script_total_ms) }}</strong></td></tr>
</table>
<p style="font-size:.8rem;color:#888">
  <strong>Note:</strong> Timing covers setup through <code>patrol_run</code> only. Not included:
  last test's backend reset + provisioning, patrol teardown, patrol test report display,
  Docker Compose teardown, and other post-run cleanup operations.
</p>
{% endif %}

{% if chart_html %}
<div class="chart">{{ chart_html }}</div>
{% endif %}

{% if tests %}
<details open>
<summary><h2 style="display:inline">Test Results ({{ n_tests }} tests)</h2></summary>
{% if n_tests < 10 %}
<p class="warn">⚠️ Only {{ n_tests }} test(s) — p75/p95 percentile thresholds are not statistically meaningful below 10 runs. Color highlights (fast/medium/slow) may be misleading.</p>
{% endif %}
<table>
  <tr>
    <th>#</th><th>Status</th><th>Test</th>
    <th>App Launch</th><th>Login</th><th>Test Logic</th>
    <th>Backend Reset</th><th>Total</th>
  </tr>
  {% for t in tests %}
  <tr>
    <td style="color:#888">{{ loop.index }}</td>
    <td class="{{ t.status }}">{{ t.status }}</td>
    <td style="white-space:normal;word-break:break-word;min-width:12rem">{{ t.name }}</td>
    <td>{{ ms_to_s(t.phases.get('app_launch', 0)) }}</td>
    <td>{{ ms_to_s(t.phases.get('login', 0)) }}</td>
    <td>{{ ms_to_s(t.phases.get('test_logic', 0)) }}</td>
    <td>{{ ms_to_s(t.phases.get('backend_reset', 0)) }}</td>
    <td class="{{ highlight(t.total_ms, p75, p95) }}">{{ ms_to_s(t.total_ms) }}</td>
  </tr>
  {% if t.steps %}
  <tr><td colspan="8" style="padding-left:2rem;padding-bottom:.5rem">
    <details open>
      <summary style="color:#4e79a7;cursor:pointer">{{ t.steps|length }} steps (click to collapse)</summary>
      <table style="margin-top:.3rem">
        <tr><th>Step</th><th>Phase</th><th>Duration</th><th style="min-width:8rem">Share</th></tr>
        {% set phase_ms = namespace(login=0, launch=0, logic=0) %}
        {% for s in t.steps %}
          {% if step_phase(s['name']) == 'login' %}{% set phase_ms.login = phase_ms.login + s['ms'] %}{% endif %}
          {% if step_phase(s['name']) == 'app_launch' %}{% set phase_ms.launch = phase_ms.launch + s['ms'] %}{% endif %}
          {% if step_phase(s['name']) == 'test_logic' %}{% set phase_ms.logic = phase_ms.logic + s['ms'] %}{% endif %}
        {% endfor %}
        {% set step_total = phase_ms.login + phase_ms.launch + phase_ms.logic %}
        {% for s in t.steps %}
        {% set sphase = step_phase(s['name']) %}
        {% set bar_w = (s['ms'] / step_total * 100) | int if step_total else 0 %}
        <tr>
          <td class="step-{{ 'login' if sphase == 'login' else ('launch' if sphase == 'app_launch' else 'logic') }}">{{ s['name'] }}</td>
          <td style="font-size:.8rem;color:#888">{{ sphase }}</td>
          <td>{{ ms_to_s(s['ms']) }}</td>
          <td>
            <span class="bar-wrap"><span class="bar-fill" style="width:{{ bar_w }}%;background:{{ '#f28e2b' if sphase == 'login' else ('#4e79a7' if sphase == 'app_launch' else '#59a14f') }}"></span></span>
            {{ pct(s['ms'], step_total) }}
          </td>
        </tr>
        {% endfor %}
      </table>
    </details>
  </td></tr>
  {% endif %}
  {% endfor %}
</table>
</details>
{% endif %}

{% if overhead_rows %}
<h2>Overhead vs Useful Work</h2>
<p class="info">ℹ️ <strong>Overhead</strong> = app_launch + login + backend_reset. <strong>Useful work</strong> = test_logic. High overhead means each test spends most of its time on infrastructure, not the feature under test.</p>
<table>
  <tr><th>Test</th><th>Overhead</th><th>Overhead %</th><th>Test Logic</th><th>Logic %</th><th>Total</th></tr>
  {% for r in overhead_rows %}
  <tr>
    <td style="white-space:normal;word-break:break-word;min-width:12rem">{{ r['name'] }}</td>
    <td>{{ ms_to_s(r['overhead_ms']) }}</td>
    <td>
      <span class="bar-wrap"><span class="bar-fill" style="width:{{ (r['overhead_ms'] / r['total_ms'] * 100)|int }}%;background:#e15759"></span></span>
      {{ r['overhead_pct'] }}
    </td>
    <td>{{ ms_to_s(r['logic_ms']) }}</td>
    <td>
      <span class="bar-wrap"><span class="bar-fill" style="width:{{ (r['logic_ms'] / r['total_ms'] * 100)|int }}%;background:#59a14f"></span></span>
      {{ r['logic_pct'] }}
    </td>
    <td>{{ ms_to_s(r['total_ms']) }}</td>
  </tr>
  {% endfor %}
  {% set tot_overhead = overhead_rows | sum(attribute='overhead_ms') %}
  {% set tot_logic = overhead_rows | sum(attribute='logic_ms') %}
  {% set tot_total = overhead_rows | sum(attribute='total_ms') %}
  <tr style="font-weight:600;background:#f5f5f5">
    <td>Total (all tests)</td>
    <td>{{ ms_to_s(tot_overhead) }}</td>
    <td>{{ pct(tot_overhead, tot_total) }}</td>
    <td>{{ ms_to_s(tot_logic) }}</td>
    <td>{{ pct(tot_logic, tot_total) }}</td>
    <td>{{ ms_to_s(tot_total) }}</td>
  </tr>
</table>
{% endif %}

{% if patrol_fw %}
<h2>Patrol Framework Overhead</h2>
{% if inter_test_timeline %}
<p class="info">ℹ️ Full inter-test timeline below — all patrol_run time is categorized. Patrol-internal segments (pre-first-test, inter-test gaps, setUp→test delay, post-last-test) cannot be sub-divided without modifying patrol source.</p>
{% else %}
<p class="warn">⚠️ {{ pct(patrol_fw['unaccounted_ms'], patrol_fw['patrol_run_ms']) }} of <code>patrol_run</code> ({{ ms_to_s(patrol_fw['unaccounted_ms']) }}) is unaccounted — no [EVENT] data in this log. Run with RESET_SERVER_URL to enable full inter-test timeline.</p>
{% endif %}
<table>
  <tr><th>Metric</th><th>Duration</th><th>% of patrol_run</th></tr>
  <tr><td>patrol_run total</td><td>{{ ms_to_s(patrol_fw['patrol_run_ms']) }}</td><td>100%</td></tr>
  <tr><td>Sum of TIMING_REPORT totals</td><td>{{ ms_to_s(patrol_fw['sum_test_ms']) }}</td><td>{{ pct(patrol_fw['sum_test_ms'], patrol_fw['patrol_run_ms']) }}</td></tr>
  <tr style="color:#d32f2f;font-weight:600"><td>Unaccounted (patrol framework + inter-test)</td><td>{{ ms_to_s(patrol_fw['unaccounted_ms']) }}</td><td>{{ pct(patrol_fw['unaccounted_ms'], patrol_fw['patrol_run_ms']) }}</td></tr>
</table>
{% endif %}

{% if inter_test_timeline %}
<h2>Inter-Test Timeline (patrol_run breakdown)</h2>
<p style="font-size:.8rem;color:#888">
  Reconstructed from server-side <code>[EVENT]</code> timestamps correlated with shell-side absolute timestamps.
  Events: <code>harness_setup</code> / <code>test_body_start</code> / <code>harness_teardown_end</code> (device-side) +
  <code>patrol_run_start</code> / <code>patrol_run_end</code> (shell-side).
  <strong>patrol_framework</strong> rows = patrol internal overhead (not instrumentable without patrol source changes).
  <strong>test_execution</strong> rows = TIMING_REPORT totals (our measured time).
  When <code>test_body_start</code> events are present, within-test overhead is split into
  "setUp→test delay" (patrol scheduling) and "post-test HTTP" (/timing + /event round-trips).
</p>
<table>
  <tr><th>Segment</th><th>Phase</th><th>Duration</th><th style="min-width:10rem">Share of patrol_run</th><th>Detail</th></tr>
  {% set pr_ms = patrol_fw['patrol_run_ms'] if patrol_fw else 1 %}
  {% for row in inter_test_timeline %}
  <tr style="{{ 'background:#fff3e0' if row['phase'] == 'patrol_framework' else '' }}">
    <td style="white-space:normal;word-break:break-word">{{ row['label'] }}</td>
    <td style="font-size:.85rem;color:{{ '#e07b00' if row['phase'] == 'patrol_framework' else '#4e79a7' }}">{{ row['phase'] }}</td>
    <td>{{ ms_to_s(row['ms']) }}</td>
    <td>
      <span class="bar-wrap"><span class="bar-fill" style="width:{{ [(row['ms'] / pr_ms * 100)|int, 100]|min }}%;background:{{ '#e07b00' if row['phase'] == 'patrol_framework' else '#4e79a7' }}"></span></span>
      {{ pct(row['ms'], pr_ms) }}
    </td>
    <td style="font-size:.8rem;color:#555">
      {{ row['detail'] }}
      {% if row.get('within_gap_ms') is not none %}
        {% if row['within_gap_ms'] > 0 %}
        <br><span style="color:#e07b00">+{{ ms_to_s(row['within_gap_ms']) }} within-test patrol gap</span>
        {% endif %}
      {% endif %}
    </td>
  </tr>
  {% endfor %}
</table>
{% endif %}

{% if resets %}
<h2>Backend Reset Breakdown</h2>
<p style="font-size:.8rem;color:#888">
  <strong>Note:</strong> Each reset clears domain data and vault, then provisions fresh test data
  for the next phase. "Dart total" = dart-side elapsed (network + server). "Server total" = server-side processing only.
  "Network overhead" = dart - server gap (HTTP round-trip + Dart GC/scheduling).
</p>
<table>
  <tr><th>#</th><th>Test</th><th>Delete Domain Data</th><th>Delete Vault</th>
      <th>Restore Backup (% of server)</th><th>Server Total</th><th>Dart Total</th><th>Network Overhead</th></tr>
  {% for row in reset_network_rows %}
  <tr>
    <td>{{ loop.index }}</td>
    <td style="color:#555;font-size:.85rem">{{ row['test_name'] }}</td>
    <td>{{ ms_to_s(resets[loop.index0].delete_domain_data_ms) }}</td>
    <td>{{ ms_to_s(resets[loop.index0].delete_user_vault_ms) }}</td>
    <td>{{ ms_to_s(row['restore_backup_ms']) }} <span style="color:#888;font-size:.8rem">({{ row['restore_backup_pct'] }})</span></td>
    <td>{{ ms_to_s(row['server_ms']) }}</td>
    <td>{{ ms_to_s(row['dart_ms']) }}</td>
    <td style="color:#e07b00">+{{ ms_to_s(row['overhead_ms']) }} <span style="font-size:.8rem">({{ row['overhead_pct'] }})</span></td>
  </tr>
  {% endfor %}
</table>
<p class="info">ℹ️ Mailbox restore (backup.zip via WebAdmin) is the dominant reset step. Delete domain data and vault clear complete first.</p>
{% endif %}

</body>
</html>'''


def generate_html(log: ParsedLog, output_path: Path) -> None:
    try:
        from jinja2 import Environment
    except ImportError:
        print("Error: jinja2 not installed. Run: pip install jinja2", file=sys.stderr)
        sys.exit(1)

    totals = [t.total_ms for t in log.tests]
    totals_sorted = sorted(totals)
    n = len(totals_sorted)
    p75 = totals_sorted[int(n * 0.75)] if n else 0
    p95 = totals_sorted[int(n * 0.95)] if n else 0

    n_passed = sum(1 for t in log.tests if t.status == 'passed')
    n_failed = sum(1 for t in log.tests if t.status == 'failed')

    chart_html = generate_plotly_stacked_bar(log.tests) if log.tests else ''
    overhead_rows = compute_overhead_rows(log.tests)
    patrol_fw = compute_patrol_framework_overhead(log.script_phases, log.tests)
    reset_network_rows = compute_reset_network_rows(log.tests, log.resets)
    inter_test_timeline = compute_inter_test_timeline(log)

    env = Environment()
    env.globals['ms_to_s'] = ms_to_s
    env.globals['highlight'] = highlight_class
    env.globals['enumerate'] = enumerate
    env.globals['pct'] = pct
    env.globals['step_phase'] = step_phase

    html = env.from_string(_TEMPLATE).render(
        n_tests=len(log.tests),
        n_resets=len(log.resets),
        n_passed=n_passed,
        n_failed=n_failed,
        chart_html=chart_html,
        script_phases=log.script_phases,
        script_total_ms=log.script_total_ms,
        phase_desc=PHASE_DESCRIPTIONS,
        tests=log.tests,
        resets=log.resets,
        p75=p75,
        p95=p95,
        overhead_rows=overhead_rows,
        patrol_fw=patrol_fw,
        reset_network_rows=reset_network_rows,
        inter_test_timeline=inter_test_timeline,
    )

    output_path.write_text(html, encoding='utf-8')
    print(f"Report written to: {output_path}")


# ── Entry point ───────────────────────────────────────────────────────────────

def main() -> None:
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)

    input_arg, output_arg = sys.argv[1], sys.argv[2]

    if input_arg == '-':
        lines = sys.stdin.readlines()
    else:
        lines = Path(input_arg).read_text(encoding='utf-8', errors='replace').splitlines()

    log = parse_log(lines)

    if not log.tests and not log.script_phases:
        print(
            "Warning: no timing tags found in input. Did you run with 2>&1 | tee?",
            file=sys.stderr,
        )

    generate_html(log, Path(output_arg))


if __name__ == '__main__':
    main()
