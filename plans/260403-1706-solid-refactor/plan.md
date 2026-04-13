---
title: "SOLID Refactor — Abstract Pattern Plan"
description: "Patterns, contracts, and protocol for decomposing god controllers. Per-controller work deferred to JIT phase files."
status: pending
priority: P1
effort: foundation: 2w · pilot delegate: 2d · per-controller: JIT
branch: refactor/solid-controller-decomposition
tags: [solid, refactor, getx, delegates, registries, architecture]
updated: 2026-04-13
---

## Overview

The presentation layer has accumulated god controllers that violate SOLID. This plan establishes the **patterns, contracts, and enforcement** needed to decompose any god controller in the codebase — **without naming specific targets**. Per-controller decomposition work is deferred and tackled one controller at a time after the foundation lands.

### Goal

After this plan's foundation phases (0–2) land, adding a new delegate to any screen is one file + one `late final` line in a domain registry. Zero bindings edits. CI gates every controller >700 LOC on every PR, ratcheting down as controllers are decomposed.

### Two-layer structure

**Layer 1 — Abstract foundation (Phases 0–2):** Infrastructure, tooling, pattern template, and one production pilot delegate. Written once; applies to every god controller. Lands on `master` non-blocking.

**Layer 2 — Per-controller phases (JIT):** One phase file created when each controller is tackled. Contains that controller's domain boundary table, Rx var inventory, delegate specs, and extraction order. Not written upfront.

### Progressive declaration rule

> Declare each artifact in the same commit that creates the thing needing it.
> Never declare upfront for work that doesn't exist yet.

| Artifact | When to add |
|---|---|
| ISP interface `IXRepository` | Same commit as the delegate depending on it |
| CI ratchet threshold update | After a delegate is extracted, tested, and CI green |
| Event class file | Same commit as the first delegate that emits/listens to it |
| Registry `late final` field | Same commit as the delegate it exposes |
| New controller phase file (Layer 2) | Moment you start work on that controller |

### Core patterns (established in Phases 0–2)

| Pattern | Purpose | Phase |
|---|---|---|
| `ControllerDelegate` (plain Dart class) | Units of decomposition. Owns workers + subscriptions. Lifecycle driven by parent registry. | 0 |
| `AppEventBus` + wrapper events | Cross-feature announcements. Domain `Success`/`Failure` wrapped — never inherit `AppEvent`. | 1 |
| `SessionService` (constructor-injected EventBus) | Single source of truth for session. Written only by `SessionEstablishedEvent`. | 1 |
| State services with single-writer rule | Shared Rx state with named owning delegate. | 1 |
| `ActionQueue` + `DomainAction` + `CancellationToken` | Centralised async execution. Tag-unique, cancel-before-replace, `cancelAll()`. | 1 |
| `ControllerDelegate` base + lifecycle propagation via `DomainRegistry` | Delegates get `init()`/`dispose()` called deterministically by their registry. | 1 |
| `BaseController` strip + `ViewContextService` + `AuthService` / `CacheService` / `UIService` | Lean base for delegates to extend when a GetxController is needed. | 2 |
| Domain Registry lifecycle propagation | Single DI entry per domain; owns its delegates' init/dispose. | 2 |
| Pilot delegate shipped to production | Proves the full loop before touching any god controller. | 2 |
| Per-controller extraction protocol | Generic template for JIT Layer 2 phases. | N |

### Zero-tolerance regression rules (enforced by CI on every commit)

1. `workerObxVariables.add(ever(...))` for GetxControllers; `trackWorker(ever(...))` for `ControllerDelegate`. Never bare `ever()`.
2. `consumeState()` is `@Deprecated`. Zero NEW callers in delegates or registries.
3. Every `ControllerDelegate` with EventBus subscriptions stores and cancels them in `dispose()`.
4. `SessionService` has no public setter; writes only happen in its own `SessionEstablishedEvent` listener.
5. One delegate per commit, CI green before the next extraction starts.
6. Each decomposition phase file owns the event files it introduces — no cross-phase edits to event files.
7. `Get.find<>()` never inside extension methods, mixin bodies, or delegate bodies. Bindings + registries only.
8. `XBindings().dependencies()` never called from a controller body. Accepted exceptions: `inject*()` methods in `BaseController`/`ReloadableController` (capability-gated), `fcm_message_controller.dart` (background isolate bootstrap).
9. Domain `Success`/`Failure` types never extend `AppEvent`. Cross-feature delivery uses wrapper events (`ActionCompleted<T>` or named events).
10. `ActionQueue.submit()` cancels any existing subscription for the same `tag` before installing a new one.
11. `ActionQueue.cancelAll()` called on `onSessionEnd()` — no orphaned streams survive logout.
12. Controllers >700 LOC are CI-gated; the gate auto-discovers new violators.
13. `ControllerDelegate` is a plain Dart class (not a `BaseController`). It does not appear in `Get.find<>()` directly — it is owned by its registry.
14. State services expose a single `update*` method per Rx var, documented with the name of the delegate allowed to call it.

## Phases

> **Non-blocking by design.** Phases 0–1 are additive; land directly on `master`. Phase 2 is a 4-day coordination window (BaseController + bindings files only). Layer 2 per-controller phases run in git worktrees.

| # | Phase | Blocking | Effort | Status | File |
|---|-------|----------|--------|--------|------|
| 0 | Safety Foundation: `workerObxVariables` → `BaseController`, `consumeState()` stream fix + deprecation, `ControllerDelegate` abstract base, auto-discovering CI script, `custom_lint` rules | Non-blocking | 2d | pending | [phase-00](phase-00-safety-foundation.md) |
| 1 | Core Infrastructure: `AppEventBus` + wrapper events, constructor-injected `SessionService`, state services with single-writer rule, `ActionQueue` + `DomainAction` + `CancellationToken` (cancel-before-replace, `cancelAll()`), generic characterization test template | Non-blocking | 3d | pending | [phase-01](phase-01-new-infrastructure.md) |
| 2 | BaseController & DI Refactor + Pilot: `BaseController` strip (→≤250 LOC), `ReloadableController` ctor injection, `AuthService` / `CacheService` / `UIService` / `ViewContextService` extraction, bindings split, panel-scoped binding migration, **NotificationDelegate pilot shipped to production** | **Coordination window** | 4d | pending | [phase-02](phase-02-base-refactor-and-di.md) |
| N | Generic per-controller extraction protocol (template). One instance created JIT per god controller, smallest LOC first. Run in git worktrees. Includes Rxn→EventBus migration per delegate. | Non-blocking (git worktree) | per controller | template | [phase-N-template](phase-N-generic-controller-extraction.md) |

Layer 2 per-controller phase files are created JIT when work on each controller begins. They are **not** pre-written in this plan.

## Foundation targets

These targets apply after Phases 0–2 land:

| Metric | Target | Verified by |
|--------|--------|-------------|
| `BaseController` LOC | ≤250 | CI (`BASE_MAX=250`) |
| `ReloadableController` field-level `Get.find` | 0 | CI |
| Bare `ever()` calls | 0 (ratcheted from baseline) | CI |
| `Get.find<>()` outside bindings | ≤ current baseline, ratchets down | CI |
| `XBindings().dependencies()` outside bindings | 0 | CI |
| Cross-feature `DataSource` in bindings | 0 | CI |
| Pilot delegate shipped | NotificationDelegate in production | Smoke test |
| Controllers >700 LOC | Auto-discovered + gated (no regressions) | CI (`controller_loc_gate`) |

Per-controller targets (LOC reduction, delegate count, Rxn elimination) are owned by each Layer 2 phase file and recorded when that controller's decomposition begins.

## Dependencies

- Phase 0 → additive, no blockers. Establishes CI enforcement at current baselines.
- Phase 1 → additive, no blockers. Can run immediately after or in parallel with Phase 0.
- Phase 2 → depends on Phases 0 + 1. **Only phase requiring team coordination** (4-day window).
- Phase 2 → blocks all Layer 2 decomposition phases. BaseController must be lean before any delegate extends it (for cases where a delegate must be a `BaseController` subclass — though the canonical `ControllerDelegate` is a plain Dart class).
- Layer 2 phases → run in git worktrees, may be parallelised across controllers. Feature PRs land on `master` freely throughout.

## Out of scope for this plan

The following are deferred to Layer 2 phase files (JIT) or later initiatives:

- **Specific god controller decomposition.** No controller is named in actionable targets.
- **Cross-feature decoupling.** Each Layer 2 phase handles its own cross-feature cleanup.
- **Session lifecycle protocol integration** in existing login/logout flow. Registered as a contract in Phase 1; wired into production by the first Layer 2 phase that requires session-scoped registries.
- **Operation lifetime reclassification** (`DownloadService`, `SendingQueueService`, etc.). Addressed when the owning controller is decomposed.
- **Documentation sweep** (`docs/system-architecture.md`, ADR "actual metrics" section). Happens after enough Layer 2 phases land to have representative numbers.
