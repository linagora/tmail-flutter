# 86. Android Composer: Draft Loss When App Goes to Background

Date: 2026-04-28

## Status

Proposed

## Related ADRs

- [ADR-0085](./0085-riverpod-state-management-for-local-settings.md) — Riverpod coexistence pattern with GetX
- [ADR-0009](./0009-on-before-unload-not-support-indexed-db.md) — Web composer cache on browser unload

## Context

### Problem

While composing a new email on Android, if the user switches to another app, Android can silently terminate the Twake Mail WebView renderer process (on low-memory devices or Xiaomi MIUI). When the user returns, the composer shows a blank editor and the email content is irrecoverably lost. On severe memory pressure, the entire app process can also be killed, forcing a full restart with no composer state.

This is reproducible specifically on:
- Low-spec Android devices (< 3 GB RAM)
- Xiaomi/MIUI devices (aggressive `lowmemorykiller` daemon)

### Findings

#### RC1 (Primary) — WebView Renderer Process Kill

Android runs `InAppWebView` rendering in a **separate OS process** (the renderer process), distinct from the Flutter/Dart app process. When memory pressure occurs, the Android OOM killer assigns a higher `oom_adj` score to the renderer process compared to the foreground app, meaning the renderer is killed first.

```text
Android OOM Killer
    │
    ├── Flutter app process  (oom_adj: low)  ← remains alive
    │       └── Dart VM, GetX controllers, Hive
    │
    └── WebView renderer process (oom_adj: high) ← killed first
            └── HTML content in editor          ← LOST
```

When the renderer dies:
- `InAppWebView` displays a blank/white page
- `htmlEditorApi?.getText()` throws or returns empty
- The Flutter app process is still alive but the editor content is gone

**`flutter_inappwebview` provides `onRenderProcessGone` on `InAppWebView`, but `enough_html_editor` (which wraps `InAppWebView` internally) does not expose this callback to callers.** The `InAppWebView` in `enough_html_editor/src/editor.dart` is constructed without forwarding this handler, leaving the renderer kill completely silent at the application level.

#### RC2 (Secondary) — Full App Process Kill

On extreme memory pressure, Android kills the entire app process. On restart, no composer state is restored.

#### The Timing Window

```text
User switches to another app
        │
        ▼
AppLifecycleState.inactive  ← WebView renderer still alive — SAFE WINDOW to extract content
        │ (~300ms – 2s)
        ▼
AppLifecycleState.paused    ← renderer may begin dying
        │ (seconds to minutes)
        ▼
[Android kills WebView renderer] ← content GONE, too late
        │
        ▼
[Android kills app process]      ← content GONE, too late
```

The only reliable window to call `htmlEditorApi?.getText()` is at `AppLifecycleState.inactive`.

#### Distinguishing System Kill from User-Initiated Close

On Android, when the user **swipes the app away from the Recents list**, Flutter fires `AppLifecycleState.detached` (`onDetach` in `AppLifecycleListener`) before the process is killed. When the **system kills the process** due to memory pressure, the process dies silently — `onDetach` is never called.

This means the two scenarios are technically distinguishable. However, a user swiping the app away while composing is **not** a deliberate choice to discard the draft — it is an OS-level action, not an in-app "Discard" decision. Losing the draft due to an accidental swipe is poor UX.

Therefore `isCleanClose = true` is set **only** on explicit in-app discard actions. `onDetach` does not set the flag.

| Scenario | `isCleanClose` | Reason |
|---|---|---|
| User taps X (delete composer) | `true` | Explicit in-app discard |
| User closes composer → chooses Discard | `true` | Explicit in-app discard |
| Draft saved to server successfully, then closed | `true` | Content already persisted |
| Email sent successfully | `true` | Draft no longer needed |
| User swipes app away from Recents (`onDetach`) | `false` | OS-level action, not an in-app discard decision |
| System kills process (no `onDetach`) | `false` | Involuntary — always restore |

The `isCleanClose` flag, persisted alongside the cached content, is the discriminant.

---

## Decision

### Four-Layer Defence Strategy

#### Layer 1 — Proactive Local Cache at `AppLifecycleState.inactive`

Add an `AppLifecycleListener` to `ComposerController` (mobile only). On `onInactive`, extract the current editor HTML, build a `CreateEmailRequest` from all composer fields (recipients, subject, identity, attachments), then call `SaveComposerCacheOnMobileInteractor` which generates the full `Email` object via `ComposerRepository.generateEmail()` and persists a `ComposerCache` entry to the Hive box (`composerMobileCache`) keyed by `_mobileSessionId`.

> **`composerId`** is a web-only concept managed by `ComposerManager` to support multiple simultaneous composer instances on desktop browsers. On mobile, `ComposerBindings` is always instantiated without a `composerId` (it is `null`). Therefore, the mobile cache uses a separate **`_mobileSessionId`**: a UUID generated inside `ComposerController.onInit()` on mobile only. Since mobile allows only one composer at a time (full-screen route), a single UUID per session is sufficient as the direct cache key. It is passed to the repository methods at every call site — no computed getter is needed. On mobile, `_mobileSessionId` is stored as the `composerId` field value inside `ComposerCache` (see "Reusing `ComposerCache` for mobile" below).

This is the primary fix for both RC1 and RC2. It is fast, offline, and does not depend on network connectivity.

**Fallback for `getText()` failure**: a periodic content snapshot (`Timer.periodic(30s)`) runs while the editor is loaded, storing the last known HTML in `_lastKnownContent`. At `inactive`, extraction uses `try/catch` around `getText().timeout(2s)`. On any exception — timeout, renderer crash, or empty result — the fallback is `_lastKnownContent`. This ensures Layer 1 persistence is never silently skipped.

**System dialog false positive**: `AppLifecycleState.inactive` is also triggered by system overlays (permission dialogs, incoming calls, notification shade). To avoid unnecessary saves in these cases, the save is preceded by a short guard delay (~300 ms). If the state returns to `active` within that window, the save is cancelled. This prevents both the Layer 1 Hive write and the Layer 2 network call from triggering unnecessarily when the user never actually leaves the app.

**In-progress attachment uploads**: if the user backgrounds the app while an attachment is still uploading, that attachment will not yet have a `blobId`. Only completed attachments (with a resolved `blobId`) are included in the `ComposerCache` snapshot. In-progress attachments are omitted and must be re-uploaded after restore. This is a known limitation documented in the Negative consequences.

#### Layer 2 — Silent Server-Side Draft Save at `AppLifecycleState.inactive`

Layer 1 is `await`ed before Layer 2 is triggered. Once the Hive write completes, `CreateNewAndSaveEmailToDraftsInteractor` is fired without `await` (fire-and-forget) — `_onAppInactive()` does not block on the network call. This saves the draft to the JMAP server, protecting against RC2 even if the local cache is later lost (e.g. app data cleared).

**Why `inactive` and not `paused`**: at `AppLifecycleState.paused`, Android Doze mode and app-standby buckets may throttle or block outbound network traffic before the request completes. `inactive` is before the compositor is frozen, giving the network call the best chance of completing while the renderer is still alive.

This is **fire-and-forget** — failure is reported via `SentryManager.instance.captureException(exception, level: SentryLevel.warning)` but not surfaced to the user. The draft will appear in the Drafts folder on success.

**Privacy requirement**: exceptions reported to Sentry MUST NOT include the email body HTML, subject, recipient addresses, or `identityJson`. Log only the exception type and error code to avoid exfiltrating sensitive draft content through telemetry.

> **Why `captureException` and not `addBreadcrumb`**: breadcrumbs are only uploaded to Sentry when a subsequent error event is captured. A silent fire-and-forget failure never triggers such an event, so the breadcrumb would be silently lost. `captureException` sends the event immediately and independently, guaranteeing visibility.

**Deduplication guard**: a boolean `_isSavingToDraftInProgress` flag on `ComposerController` ensures only one server-side save runs at a time. If `onInactive` fires again (e.g., user rapidly switches apps back and forth) while a save is still in flight, the duplicate trigger is silently skipped. The flag is cleared on completion (success or failure). Note that Layer 1 (Hive write) is also protected by the 300 ms guard described above — the deduplication flag applies only to the Layer 2 network call.

#### Layer 3 — Recovery at `AppLifecycleState.resumed` / `onReady` (RC1)

On `ComposerController.onReady()` (mobile only), check whether a non-clean-close cache entry exists for the current `_mobileSessionId`. If found, inject the cached HTML into the editor and restore all composer fields. Delete the cache entry after successful restoration.

On `AppLifecycleState.resumed`, check if the editor is blank (renderer was killed while app stayed alive) and a non-clean cache entry exists. If so, reinject the cached content.

**Cache-cleared edge case**: if Layer 2 succeeded and cleared the local cache before the user returns, Layer 3 `onResumed` will find no cache entry and will not reinject. In this case the draft is safely persisted in the Drafts folder on the server; the user can open it from there. No data is lost.

#### Layer 4 — Re-open Composer on App Restart (RC2)

When Android kills the entire app process, `ComposerController` is destroyed along with the route stack. Any recovery logic inside `ComposerController` will never be called because the controller no longer exists.

Recovery for RC2 must happen at a higher level — `MailboxDashBoardController.onReady()` — which always runs when the app restarts. On startup:

1. `MailboxDashBoardController` reads all valid entries (mobile only) via `appProviderContainer.read(composerAutoSaveProvider.notifier).restoreAll()` (filter: `isCleanClose = false`, age < 24 h). `MailboxDashBoardController` is a GetX controller and follows the same `appProviderContainer.read(...)` pattern as `ComposerController`.
2. If one or more entries exist, the dashboard MUST select exactly one deterministically — the **newest by `timestampMs`** — and open the composer with that snapshot as `ComposerArguments`. Any older stale entries are cleared immediately.
3. `ComposerController.onReady()` then proceeds with Layer 3 to inject the content into the editor.
4. The restored cache entry is cleared after successful injection.

```text
App process restarted
        │
        ▼
MailboxDashBoardController.onReady()  [mobile only]
        │
        ├── appProviderContainer.read(composerAutoSaveProvider.notifier).restoreAll()
        │                                          ← filter: !cleanClose, age < 24h
        │
        ├── entries found?
        │       ├── pick newest by timestampMs
        │       ├── clear remaining stale entries
        │       └── openComposer(ComposerArguments.fromSnapshot(snapshot))
        │                           │
        │                           ▼
        │                   ComposerController.onReady()
        │                           └── Layer 3: inject content into editor
        │
        └── no entries / all clean → normal startup flow
```

This mirrors the existing web behaviour where `reopenComposerBrowser` (`EmailActionType`) restores a cached composer on page reload.

### Architecture

```text
ComposerController (GetX)  [mobile only]
    │
    ├── AppLifecycleListener
    │       ├── onInactive → _onAppInactive()
    │       └── onResume   → _onAppResumed()
    │
    ├── _onAppInactive()
    │       ├── [300ms guard — cancels if state → active]
    │       ├── try { content = await getText().timeout(2s) }
    │       │   catch (_) { content = _lastKnownContent }
    │       ├── await Layer 1: appProviderContainer.read(composerAutoSaveProvider(_saveComposerCacheInteractor).notifier)
    │       │                       .save(_mobileSessionId, ...)          ← Hive write
    │       └── fire Layer 2: CreateNewAndSaveEmailToDraftsInteractor     ← unawaited
    │
    ├── onReady() [RC1 Scenario A — fresh open after renderer kill]
    │       └── _checkAndRestoreComposerCache(_mobileSessionId)
    │
    ├── _onAppResumed() [RC1 Scenario B — user returns, editor blank]
    │       └── editor blank + cache entry exists?
    │               └── _checkAndRestoreComposerCache(_mobileSessionId)
    │
    ├── _closeComposerAction() [mark clean — mobile only]
    │       └── appProviderContainer.read(composerAutoSaveProvider(_saveComposerCacheInteractor).notifier)
    │                   .markCleanClose(_mobileSessionId)
    │
    └── onClose() [mobile only]
            └── appProviderContainer.invalidate(composerAutoSaveProvider(_saveComposerCacheInteractor))
```

```text
ComposerAutoSaveNotifier (Riverpod StateNotifier)
    │   [family param: SaveComposerCacheOnMobileInteractor — constructed by ComposerController]
    │
    ├── save(sessionId, CreateEmailRequest)   → SaveComposerCacheOnMobileInteractor (family param)
    │                                               └── ComposerRepository (GetX) + ComposerMobileCacheRepository
    ├── restore(sessionId)                    → GetComposerCacheOnMobileInteractor
    ├── restoreAll()                          → GetAllComposerCacheOnMobileInteractor  [Layer 4]
    ├── markCleanClose(sessionId)             → SaveComposerCacheOnMobileInteractor (isCleanClose=true)
    └── clearById(sessionId)                  → RemoveComposerCacheByIdOnMobileInteractor
        │
        └── Get/GetAll/RemoveById → ComposerMobileCacheRepository (domain interface — NEW)
                                        └── ComposerMobileCacheRepositoryImpl (data — NEW)
                                                └── ComposerMobileCacheClient (HiveCacheClient<String> — NEW)
```

### Reusing `ComposerCache` for mobile

Rather than introducing a new model, the existing `ComposerCache` (in `mailbox_dashboard/data/model/`) is reused for mobile persistence. `ComposerCache` already carries the full `Email` object — generated via `ComposerRepository.generateEmail()` the same way `SaveComposerCacheOnWebInteractor` does — including inline images as base64 attachments, regular attachments, recipients, subject, identity, action type, and draft ID.

Two nullable fields are added to `ComposerCache` for mobile recovery logic:

```dart
// New mobile-only fields (null on all web entries — no impact on web serialisation)
final bool? isCleanClose;   // null/false = involuntary kill → restore; true = deliberate discard → skip
final int? timestampMs;     // snapshot time (ms); used for Layer 4 deterministic selection
```

`@JsonSerializable(includeIfNull: false)` is already on `ComposerCache`, so these fields are omitted from web-generated JSON entirely — zero impact on web.

`composerId` field (already in `ComposerCache`) is reused as the mobile session key: on mobile, `composerId = _mobileSessionId` (UUID generated in `onInit()`).

**Required enum change**: `EmailActionType.reopenComposerMobile` must be added to the existing `EmailActionType` enum (`model/` package). This is the action type used when restoring a cached mobile composer — analogous to the existing `reopenComposerBrowser` for web.

**Inline images for `reopenComposerMobile`**: `setup_email_attachments_extension.dart` treats `EmailActionType.reopenComposerMobile` identically to `reopenComposerBrowser` — both restore `attachments` and `inlineImages` from `ComposerCache.email`. `SaveComposerCacheOnMobileInteractor` calls `ComposerRepository.generateEmail()` at snapshot time, which embeds inline images as base64 data URIs in the `Email` body and records them in the attachment list. On restore, they are available immediately without any network fetch.

### Riverpod pattern

`ComposerAutoSaveNotifier` (Riverpod `StateNotifier`) receives mobile interactors as dependencies, mirroring the web pattern (`SaveComposerCacheOnWebInteractor`, `GetComposerCacheOnWebInteractor`, etc.). Riverpod is chosen to keep the auto-save concern isolated, independently testable, and aligned with the ADR-0075 migration roadmap. `ComposerController` (GetX) is a consumer only, via `appProviderContainer.read(...)`.

The dependency chain is managed **purely by Riverpod** via `ref.read()` — no `Get.find<>()` inside any provider.

`SaveComposerCacheOnMobileInteractor` requires `ComposerRepository` (GetX-managed). Rather than leaking `ComposerRepository` into the provider signature (ISP violation — the notifier doesn't use it directly), `ComposerController` constructs `SaveComposerCacheOnMobileInteractor` itself in `onInit()` using its own injected `_composerRepository`, then passes the ready interactor as the `family` parameter. The provider only sees interactors — its natural dependencies.

**Memory management**: `StateNotifierProvider.family` on a global `appProviderContainer` caches one entry per unique parameter. `ComposerController.onClose()` calls `appProviderContainer.invalidate(...)` to remove the entry when the composer closes. Using `autoDispose + listen` was rejected: maintaining a keep-alive listener from a GetX controller is an anti-pattern that fights the framework and risks accidental early disposal.

`composerMobileCacheRepositoryProvider` is intentionally public — `ComposerController` reads it to construct `SaveComposerCacheOnMobileInteractor`.

Follows [ADR-0085](./0085-riverpod-state-management-for-local-settings.md): providers are registered on the global `appProviderContainer`.

```dart
// All providers co-located in composer_auto_save_notifier.dart — internal providers are private (_)

final _composerMobileCacheClientProvider = Provider<ComposerMobileCacheClient>(
  (_) => ComposerMobileCacheClient(),
);

// Public: ComposerController reads this to construct SaveComposerCacheOnMobileInteractor.
final composerMobileCacheRepositoryProvider = Provider<ComposerMobileCacheRepository>(
  (ref) => ComposerMobileCacheRepositoryImpl(
    ref.read(_composerMobileCacheClientProvider),
  ),
);

final _getOnMobileProvider = Provider(
  (ref) => GetComposerCacheOnMobileInteractor(
    ref.read(composerMobileCacheRepositoryProvider),
  ),
);

final _getAllOnMobileProvider = Provider(
  (ref) => GetAllComposerCacheOnMobileInteractor(
    ref.read(composerMobileCacheRepositoryProvider),
  ),
);

final _removeByIdOnMobileProvider = Provider(
  (ref) => RemoveComposerCacheByIdOnMobileInteractor(
    ref.read(composerMobileCacheRepositoryProvider),
  ),
);

// SaveComposerCacheOnMobileInteractor is NOT wired inside this file — it needs
// ComposerRepository (GetX-managed). ComposerController constructs it and passes it as
// the family parameter, keeping GetX at the controller boundary (SOLID: ISP, SRP).
final composerAutoSaveProvider = StateNotifierProvider
    .family<ComposerAutoSaveNotifier, ComposerAutoSaveState, SaveComposerCacheOnMobileInteractor>(
  (ref, saveInteractor) => ComposerAutoSaveNotifier(
    saveInteractor,
    ref.read(_getOnMobileProvider),
    ref.read(_getAllOnMobileProvider),
    ref.read(_removeByIdOnMobileProvider),
  ),
);
```

`ComposerController` (mobile only):

```dart
// onInit() — construct interactor using own GetX-injected repository
_saveComposerCacheInteractor = SaveComposerCacheOnMobileInteractor(
  appProviderContainer.read(composerMobileCacheRepositoryProvider),
  _composerRepository,  // injected via ComposerBindings
);

// usage
appProviderContainer
    .read(composerAutoSaveProvider(_saveComposerCacheInteractor).notifier)
    .save(_mobileSessionId, ...);

// onClose() — invalidate family entry to prevent memory leak on appProviderContainer
appProviderContainer.invalidate(composerAutoSaveProvider(_saveComposerCacheInteractor));
```

### Cache eviction

- Entries older than 24 hours are ignored on restore (treated as expired).
- Entries are deleted after successful restoration or after `markCleanClose`.
- On successful server-side draft save (Layer 2), the local cache entry is also cleared.
- If the close is **not** a clean close (system kill, swipe from Recents, or any scenario where `isCleanClose` is not explicitly set to `true`), the entry remains in cache indefinitely until it is either restored by Layer 3/4, replaced by a newer snapshot, or expires after 24 hours. This is intentional: every involuntary kill must result in a restore attempt.
- `composerMobileCache` MUST use encrypted Hive storage (AES-256 cipher) with keys provided by `HiveCacheConfig`. Plaintext storage is not permitted for draft body content. The AES key is generated once by `HiveCacheConfig.initializeEncryptionKey()` on first launch and stored in device secure storage via `EncryptionKeyCacheManager` (backed by `flutter_secure_storage`). There is no scheduled key rotation — the key is stable for the lifetime of the app installation. If the key is missing after a backup/restore (Android backup does not include `flutter_secure_storage` data by default), the Hive box will fail to open; in that case the cache is treated as empty and the user must re-compose.

### What is NOT in scope

- Forwarding `onRenderProcessGone` from `enough_html_editor` to callers — tracked as a separate upstream contribution to that library. The `inactive` snapshot already covers the same scenario because the renderer is always alive at that moment.
- Migrating `ComposerController` from GetX to Riverpod — that is part of the broader ADR-0075 migration roadmap.
- Restoring uploaded attachment binaries — blobs are already on the server; only metadata is needed.
- Restoring in-progress (mid-upload) attachments — attachments without a resolved `blobId` at snapshot time are omitted. The user must re-upload them after restore.

---

## Consequences

### Positive

- Draft content is preserved across Android background kills (both renderer-only and full process), without any user action required. On full process kill (RC2), the composer is automatically re-opened on next app launch.
- Although the root cause (RC1 — WebView renderer kill) is Android-specific, Layers 1–4 run on iOS as well. iOS users benefit from the same protection if the app is terminated in the background, even though the WKWebView renderer is less aggressively killed on iOS than Android.
- The fix is additive — no existing save/close/send logic is changed in behaviour.
- Follows the established Riverpod coexistence pattern (ADR-0085) for the new state logic.
- Layer 2 (silent server save) gives users a fallback in Drafts even if local cache is unavailable.
- The `isCleanClose` discriminant ensures intentional discards are not accidentally restored.
- Cache entries auto-expire after 24 hours — no unbounded Hive growth.

### Negative

- Two `AppLifecycleListener` instances will exist on mobile per open composer (one already exists in `WebSocketController`). This is acceptable; each is scoped to its owning controller's lifecycle.
- The periodic snapshot timer (30 s) adds a minor recurring async cost while the composer is open. This is negligible compared to the existing WebView overhead.
- The `isCleanClose` write path must be added to **all** explicit-discard code paths. Missing one would cause a phantom restore. This must be enforced via code review and covered by unit tests.
- `enough_html_editor`'s `onRenderProcessGone` gap remains unaddressed. If the renderer is killed between the `inactive` snapshot and the user returning (rare), the snapshot may be stale by a few seconds.
- Local cache stores HTML content including potentially sensitive email body text. Encryption at rest is mandatory (see Cache eviction). This is consistent with the existing web `ComposerCache` behaviour and is scoped to the device's Hive storage (no additional network exposure).
- Attachments that are still uploading when the user backgrounds the app will not be included in the `ComposerCache` snapshot (no `blobId` yet). These must be re-uploaded after restore. This is a known limitation.

## References

- [TF-4473 — Android app crash when composing and app goes in background](https://github.com/linagora/tmail-flutter/issues/4473)
- [flutter_inappwebview `onRenderProcessGone` source](https://github.com/pichillilorenzo/flutter_inappwebview/blob/master/flutter_inappwebview/lib/src/in_app_webview/in_app_webview.dart) — available from Android 26+ (Android 8.0); previously `androidOnRenderProcessGone`, unified and renamed in v6.x
- [Android `WebViewClient.onRenderProcessGone` official docs](https://developer.android.com/reference/android/webkit/WebViewClient#onRenderProcessGone(android.webkit.WebView,android.webkit.RenderProcessGoneDetail))
- [enough_html_editor source — `_buildEditor()` without `onRenderProcessGone`](https://github.com/linagora/enough_html_editor)
- [Android OOM killer / lowmemorykiller](https://source.android.com/devices/tech/perf/lmkd)
