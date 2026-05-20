# 0090. Migrate to Dart Pub Workspaces

Date: 2026-05-18

## Status

Accepted

## Context

Twake Mail is a monorepo with 11 sub-packages (`core`, `model`, `contact`, `forward`, `rule_filter`, `fcm`, `email_recovery`, `server_settings`, `scribe`, `labels`, `cozy`), each historically having its own `pubspec.yaml` and `pubspec.lock`.

### Before: independent resolution per package

```text
tmail-flutter/
├── pubspec.yaml        # root app
├── pubspec.lock        # root lock (independent)
├── core/
│   ├── pubspec.yaml    # declares own deps + full dependency_overrides
│   └── pubspec.lock    # resolved independently
├── model/
│   ├── pubspec.yaml    # declares own deps + full dependency_overrides
│   └── pubspec.lock    # resolved independently
└── ...                 # × 11 sub-packages, same pattern
```

Each sub-package was a fully standalone Dart package. `pub get` had to be run separately in every directory, and each produced its own lock file. Git-sourced overrides (`jmap_dart_client`, `linagora_design_flutter`, `intl_generator`) were duplicated in every `pubspec.yaml`.

This caused several problems:

- **Inconsistent dependency resolution:** Each sub-package resolved dependencies independently, making it possible for two packages to end up with different versions of the same transitive dependency.
- **Duplicate git-sourced overrides:** Any ref change had to be applied across 12 files.
- **Multiple lock files:** 12 separate `pubspec.lock` files meant CI had a weaker cache guarantee and developers had to run `pub get` in multiple directories.

## Decision

Migrate to **Dart pub workspaces** (stable since Dart 3.5 / Flutter 3.24).

### After: unified resolution at workspace root

```text
tmail-flutter/
├── pubspec.yaml        # declares workspace: [core, model, ..., cozy]
│                       # + all dependency_overrides (git sources, pins)
├── pubspec.lock        # single shared lock for the entire monorepo
├── core/
│   └── pubspec.yaml    # resolution: workspace — no lock file, no overrides
├── model/
│   └── pubspec.yaml    # resolution: workspace — no lock file, no overrides
└── ...                 # × 11 sub-packages, same pattern
```

The root `pubspec.yaml` declares a `workspace` key listing all 11 sub-packages. Each sub-package's `pubspec.yaml` adds `resolution: workspace` to opt in. Dart resolves all packages together into a **single `pubspec.lock`** at the root.

Git-sourced `dependency_overrides` (`jmap_dart_client`, `linagora_design_flutter`, `intl_generator`) are consolidated into the root `pubspec.yaml` only. Sub-packages reference these packages by name with no git spec — the root override propagates automatically.

CI workflows (`analyze-test.yaml`, `build.yaml`, `gh-pages.yaml`, `release.yaml`) are updated to hash `pubspec.lock` (root only) instead of `**/pubspec.lock`.

`build_runner 2.4.0+` supports a `--workspace` flag that discovers all workspace members and runs code generation across all packages in a single invocation. `prebuild.sh` uses this to replace 11 separate `dart run build_runner build` calls with one:

```bash
dart run build_runner build --workspace --delete-conflicting-outputs
```

## Dependency changes

The migration required upgrading several packages to be compatible with the workspace toolchain (Dart 3.9+, `json_serializable` 6.10+, `analyzer` 12.x).

### Runtime

| Package | Before | After | Reason |
|---|---|---|---|
| SDK constraint | `>=3.0.0 <4.0.0` | `>=3.9.0 <4.0.0` | Enforce minimum for workspace features and null-aware element syntax |
| `hive_ce` | `2.11.3` | `2.16.0` | Required by `hive_ce_generator 1.11.2` |
| `worker_manager` | Linagora git fork (`hotfix/worker-init-memory-leak`) | `7.2.9` (pub.dev) | Upstream PR #123 merged 2026-04-09; fix included in 7.2.8+ |
| `json_annotation` | `4.8.0` | `^4.9.0` | Required by `json_serializable 6.11+` |

### Dev

| Package | Before | After | Reason |
|---|---|---|---|
| `build_runner` | `2.4.10` | `^2.15.0` | Enables `--workspace` flag for single-invocation code generation across all workspace members |
| `json_serializable` | `6.6.1` | `^6.11.3` | Generates null-aware element syntax (Dart 3.8+); version consolidated across workspace members |
| `mockito` | `5.4.4` | `5.6.4` | Compatibility with updated `analyzer` |
| `hive_generator` | `2.0.0` (old ecosystem) | `hive_ce_generator 1.11.2` | Generator for `hive_ce`; generates `HiveRegistrar` extension, eliminating 22 manual adapter registrations in `HiveCacheConfig` |

### Dependency overrides

**New** — added to satisfy the workspace-wide toolchain version requirements:

| Package | Value | Reason |
|---|---|---|
| `meta` | `^1.18.0` | Flutter SDK pins `1.17.0`; override allows `analyzer 12.x` to resolve (annotation-only — no behavioral difference between 1.17 and 1.18) |
| `dart_style` | `3.1.8` | Needed by `analyzer 12.x` to format null-aware element syntax |
| `analyzer` | `>=12.0.0 <13.0.0` | Required by `json_serializable 6.10+` |
| `build_runner` | `^2.15.0` | `jmap_dart_client` incorrectly declares `build_runner` as a regular dependency; override pins the correct version so the workspace resolves without conflict |
| `json_serializable` | `^6.11.3` | `jmap_dart_client` incorrectly declares `json_serializable` as a regular dependency; same fix |
| `json_annotation` | `^4.9.0` | `jmap_dart_client` incorrectly declares `json_annotation` as a regular dependency; same fix |

**Updated** — existing overrides whose configuration changed:

| Package | Before | After | Reason |
|---|---|---|---|
| `intl_generator` | ref `master` | ref `upgrade-dependencies` | Updated fork branch contains fixes for `analyzer 12.x` and `dart_style 3.x` API changes required by the toolchain upgrade |

**Removed** — no longer needed:

| Package | Reason |
|---|---|
| `hive` git shim (`IO-Design-Team/hive_ce`, `overrides/hive`) | `hive_ce_generator 1.11.2` depends on `hive_ce` directly — the backward-compat shim for the old `hive` package is no longer required |

## Consequences

- A single `pubspec.lock` at the root guarantees all packages in the monorepo resolve to identical dependency versions.
- Git-sourced overrides are maintained in one place; ref bumps require a single edit.
- CI Flutter cache key is simpler and unambiguous.
- `prebuild.sh` runs one `flutter pub get` + one `dart run build_runner build --workspace` instead of 12 sequential invocations.
- Requires Dart ≥ 3.5 / Flutter ≥ 3.24 — already satisfied by the project's pinned Flutter version.
- `pub get` must be run from the root; running it inside a sub-package directory is a no-op for resolution but will not update the shared lock file.
- **No regressions confirmed:** `flutter analyze` reports no new issues, all unit tests pass, and `ios/Podfile.lock` is unchanged (the dependency upgrades have no impact on iOS native pods).
