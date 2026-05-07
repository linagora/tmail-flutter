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

Add an `AppLifecycleListener` to `ComposerController` (**Android only**). On `onInactive`, extract the current editor HTML, build a `CreateEmailRequest` from all composer fields (recipients, subject, identity, attachments), then call `SaveComposerCacheInteractor` (with `isPersistent: true`) which generates the full `Email` object via `ComposerRepository.generateEmail()` and persists a `ComposerPersistentCache` entry to the Hive box (`composer_hive_cache_box`) keyed by `autoSaveComposerId`.

> **`autoSaveComposerId`** is the composerId value from the current route arguments. On mobile, `ComposerBindings` receives a timestamp-based UUID generated when the composer route is opened. This UUID is stored as the `composerId` field inside `ComposerPersistentCache` (see "New `ComposerPersistentCache` subclass" below).

This is the primary fix for both RC1 and RC2. It is fast, offline, and does not depend on network connectivity.

**Fallback for `getText()` failure**: a periodic content snapshot (`Timer.periodic(30s)`) runs while the editor is loaded, storing the last known HTML in `notifier.lastKnownHtmlContent`. At `inactive`, extraction calls `_fetchEditorContent()` which wraps `getText()` in a `try/catch` with a 2 s timeout. The timeout prevents an indefinite hang if the JS bridge freezes (distinct from a renderer crash, which throws immediately). If the result is `null` (renderer crash or timeout), the fallback is `notifier.lastKnownHtmlContent` from the last periodic tick. The resolved effective content — either fresh or fallback, even if empty — is always passed as `htmlContent` to `buildCreateEmailRequestForAutoSave(htmlContent: effectiveContent)`, so `getText()` is never called a second time inside that method.

**System dialog false positive**: `AppLifecycleState.inactive` is also triggered by system overlays (permission dialogs, incoming calls, notification shade). To avoid unnecessary saves in these cases, the save is preceded by a short guard delay (~300 ms). If the state returns to `active` within that window, the save is cancelled. This prevents both the Layer 1 Hive write and the Layer 2 network call from triggering unnecessarily when the user never actually leaves the app.

**In-progress attachment uploads**: if the user backgrounds the app while an attachment is still uploading, that attachment will not yet have a `blobId`. Only completed attachments (with a resolved `blobId`) are included in the `ComposerCache` snapshot. In-progress attachments are omitted and must be re-uploaded after restore. This is a known limitation documented in the Negative consequences.

#### Layer 2 — Silent Server-Side Draft Save at `AppLifecycleState.inactive`

Layer 1 is `await`ed before Layer 2 is triggered. Once the Hive write completes, `CreateNewAndSaveEmailToDraftsInteractor` is fired without `await` (fire-and-forget) — `_onAppInactive()` does not block on the network call. This saves the draft to the JMAP server, protecting against RC2 even if the local cache is later lost (e.g. app data cleared).

**Why `inactive` and not `paused`**: at `AppLifecycleState.paused`, Android Doze mode and app-standby buckets may throttle or block outbound network traffic before the request completes. `inactive` is before the compositor is frozen, giving the network call the best chance of completing while the renderer is still alive.

This is **fire-and-forget** — failure is reported via `SentryManager.instance.captureException(exception, level: SentryLevel.warning)` but not surfaced to the user. The draft will appear in the Drafts folder on success.

**Privacy requirement**: exceptions reported to Sentry MUST NOT include the email body HTML, subject, recipient addresses, or `identityJson`. Log only the exception type and error code to avoid exfiltrating sensitive draft content through telemetry.

> **Why `captureException` and not `addBreadcrumb`**: breadcrumbs are only uploaded to Sentry when a subsequent error event is captured. A silent fire-and-forget failure never triggers such an event, so the breadcrumb would be silently lost. `captureException` sends the event immediately and independently, guaranteeing visibility.

**Deduplication guard**: a boolean `_isSavingToDraftInProgress` flag on `ComposerController` ensures only one server-side save runs at a time. If `onInactive` fires again (e.g., user rapidly switches apps back and forth) while a save is still in flight, the duplicate trigger is silently skipped. The flag is cleared on completion (success or failure). Note that Layer 1 (Hive write) is also protected by the 300 ms guard described above — the deduplication flag applies only to the Layer 2 network call.

#### Layer 3 — Recovery at `AppLifecycleState.resumed` (RC1)

On `AppLifecycleState.resumed`, `_restoreIfEditorBlank()` checks if the editor content is empty (renderer was killed while the app stayed alive). If so, it calls `ResolveComposerCacheForRestoreInteractor` to fetch the newest restorable snapshot and reinjects the cached HTML into the editor via `htmlEditorApi.setText()`. The snapshot is then cleared so the periodic timer can write a fresh one.

**Layer 4 → Layer 3 bridge (RC2)**: when `MailboxDashBoardController` re-opens the composer with `EmailActionType.restoreComposerFromPersistentCache`, `setupEmailContent()` routes to `_loadMobileRestoredEmailContent()` which loads the cached HTML directly. No additional `onReady()` check is required in this path — the content is delivered via `ComposerArguments`.

**Cache not cleared after Layer 2**: Layer 2 deliberately does NOT clear the Hive cache on server-save success (see Layer 2 note). If the cache happens to be absent when the user returns, Layer 3 `_restoreIfEditorBlank()` finds nothing and leaves the editor as-is. The draft is safely persisted in the Drafts folder; the user can open it from there. No data is lost.

#### Layer 4 — Re-open Composer on App Restart (RC2)

When Android kills the entire app process, `ComposerController` is destroyed along with the route stack. Any recovery logic inside `ComposerController` will never be called because the controller no longer exists.

Recovery for RC2 must happen at a higher level — `_handleSessionFromArguments()` inside `MailboxDashBoardController`, which always runs when the session is established on app restart. On startup:

1. `HandleComposerRestoreOnMobileExtension.checkAndRestoreComposerOnMobile()` calls `appProviderContainer.read(resolveComposerCacheForRestoreProvider).execute(accountId, userName)`. `ResolveComposerCacheForRestoreInteractor` fetches all cached entries, picks the **newest by `timestampMs`** via `newestLocalCache`, discards non-restorable entries, and returns the single best candidate (filter: `isRestorable == true`, age < 24 h).
2. If a restorable entry is found, the dashboard opens the composer with `ComposerArguments.fromComposerPersistentCache(cache)` which sets `emailActionType = EmailActionType.restoreComposerFromPersistentCache`.
3. `ComposerController.setupEmailContent()` detects `restoreComposerFromPersistentCache` and calls `_loadMobileRestoredEmailContent()` to inject the cached HTML. Inline images are restored via `_restoreInlineImages()`.
4. Non-restorable entries (expired or `isCleanClose=true`) are removed as a side-effect of step 1.

```text
App process restarted
        │
        ▼
MailboxDashBoardController._handleSessionFromArguments()  [Android only]
        │
        ├── checkAndRestoreComposerOnMobile()
        │       └── resolveComposerCacheForRestoreProvider.execute(accountId, userName)
        │               ← newestLocalCache: pick newest by timestampMs
        │               ← non-restorable entries removed as side-effect
        │
        ├── cache found?
        │       └── openComposer(ComposerArguments.fromComposerPersistentCache(cache))
        │               emailActionType = restoreComposerFromPersistentCache
        │                           │
        │                           ▼
        │               ComposerController.setupEmailContent()
        │                           └── _loadMobileRestoredEmailContent()
        │
        └── no restorable entry → normal startup flow
```

This mirrors the existing web behaviour where `reopenComposerBrowser` (`EmailActionType`) restores a cached composer on page reload.

### Architecture

```text
ComposerController (GetX)  [Android only]
    │
    ├── AppLifecycleListener
    │       ├── onInactive → 300ms guard → _saveSnapshotToCache()
    │       └── onResume   → _restoreIfEditorBlank()
    │
    ├── _saveSnapshotToCache()
    │       ├── freshContent = _fetchEditorContent()  ← getText().timeout(2s)
    │       ├── effectiveContent = freshContent ?? notifier.lastKnownHtmlContent
    │       ├── await Layer 1: saveComposerCacheInteractor.execute(
    │       │                       createEmailRequest: ...(htmlContent: effectiveContent),
    │       │                       isPersistent: true,
    │       │                  )                                         ← Hive write
    │       └── fire Layer 2: CreateNewAndSaveEmailToDraftsInteractor   ← unawaited
    │
    ├── _restoreIfEditorBlank()  [RC1 — user returns, editor blank]
    │       └── editor blank + resolveComposerCacheForRestoreProvider returns cache?
    │               └── htmlEditorApi.setText(cache.email.emailContentList.asHtmlString)
    │
    ├── _closeComposerAction() [mark clean — Android only]
    │       ├── markCleanClose()  ← notifier.setCleanClose() + MarkComposerCacheCleanCloseInteractor (unawaited)
    │       └── closeComposer()   ← navigation (after clean-close is already persisting)
    │
    └── onClose() [Android only]
            └── appProviderContainer.invalidate(composerAutoSaveProvider(autoSaveComposerId))
```

```text
ComposerAutoSaveNotifier (Riverpod StateNotifier)
    │   [family param: String — autoSaveComposerId]
    │
    ├── state fields: hasRecoverableSnapshot, isCleanClose,
    │                 isSavingToDraftInProgress, lastKnownHtmlContent
    │
    ├── onSnapshotSaved()          — sets hasRecoverableSnapshot = true
    ├── setCleanClose()            — sets isCleanClose = true (Hive write fired immediately in markCleanClose)
    ├── updateLastKnownContent(s)  — stores periodic snapshot for fallback
    ├── beginDraftSave() / endDraftSave()  — deduplication guard for Layer 2
    ├── restore(accountId, userName)  → ResolveComposerCacheForRestoreInteractor
    └── clearCache(accountId, userName) → RemoveAllComposerCacheInteractor
        │
        └── Restore/Clear → ComposerCacheRepository (existing)
                                └── ComposerHiveCacheClient (HiveCacheClient<String>, encryption=true)
                                        └── box: composer_hive_cache_box
```

```text
Riverpod providers  [composer_cache_providers.dart]

    _composerHiveCacheClientProvider  (private)
    _composerCacheDatasourceProvider  (private)
    composerCacheRepositoryProvider   (public)
    removeAllComposerCacheProvider    (public)
    markComposerLocalCacheCleanCloseProvider  (public)
    resolveComposerCacheForRestoreProvider    (public)

    composerAutoSaveProvider = StateNotifierProvider.family<
        ComposerAutoSaveNotifier, ComposerAutoSaveState, String>
```

### New `ComposerPersistentCache` subclass

A new subclass `ComposerPersistentCache extends ComposerCache` (in `mailbox_dashboard/data/model/`) is introduced for Android persistence. It extends `ComposerCache` — which already carries the full `Email` object generated via `ComposerRepository.generateEmail()`, including inline images as base64 attachments, regular attachments, recipients, subject, identity, action type, and draft ID — with two new nullable fields:

```dart
final bool? isCleanClose;   // null/false = involuntary kill → restore; true = deliberate discard → skip
final int? timestampMs;     // snapshot time (ms); used for Layer 4 deterministic selection
```

`@JsonSerializable(includeIfNull: false)` ensures these fields are omitted from JSON when null, so existing `ComposerCache` entries (web) are unaffected.

`composerId` (already in `ComposerCache`) is used as the cache key: on mobile, `composerId = autoSaveComposerId` (timestamp-based UUID generated when the composer route is opened).

`ComposerPersistentCache` also provides:
- `isRestorable` — `true` iff `isCleanClose != true && !isExpired && !isEmpty`
- `isExpired` — `true` when `timestampMs` is older than 24 hours
- `newestLocalCache` extension on `Iterable<ComposerCache>` — picks the `ComposerPersistentCache` with the highest `timestampMs`

**Enum change**: `EmailActionType.restoreComposerFromPersistentCache` was added to `EmailActionType` (`model/` package). This is the action type used when restoring a cached Android composer — analogous to `reopenComposerBrowser` for web.

**Inline images for `restoreComposerFromPersistentCache`**: `setup_email_attachments_extension.dart` treats `EmailActionType.restoreComposerFromPersistentCache` identically to `reopenComposerBrowser` — both restore `attachments` and `inlineImages` from `ComposerCache.email`. `SaveComposerCacheInteractor` calls `ComposerRepository.generateEmail()` at snapshot time, which embeds inline images as base64 data URIs in the `Email` body. On restore, they are available immediately without any network fetch.

### Riverpod pattern

`ComposerAutoSaveNotifier` (Riverpod `StateNotifier`) holds the in-flight auto-save state and delegates restore/clear operations to domain interactors. Riverpod is chosen to keep the auto-save concern isolated, independently testable, and aligned with the ADR-0075 migration roadmap. `ComposerController` (GetX) is a consumer only, via `appProviderContainer.read(...)`.

The dependency chain is managed **purely by Riverpod** via `ref.read()` — no `Get.find<>()` inside any provider.

`SaveComposerCacheInteractor` (which needs `ComposerRepository`, a GetX-managed dependency) is **not** a Riverpod provider. It is obtained via `Get.find<SaveComposerCacheInteractor>(tag: composerId)` in `ComposerController` and called directly from `HandleMobileAutoSaveExtension._saveSnapshotToCache()`, keeping GetX at the controller boundary (SOLID: ISP, SRP).

The `composerAutoSaveProvider` family is keyed by `String` (the `autoSaveComposerId`) rather than by the interactor, because the notifier itself does not call save — only the controller extension does. The notifier handles state tracking and restore/clear operations only.

**Memory management**: `StateNotifierProvider.family` on a global `appProviderContainer` caches one entry per unique parameter. `ComposerController.onClose()` calls `appProviderContainer.invalidate(composerAutoSaveProvider(autoSaveComposerId))` to remove the entry when the composer closes. Using `autoDispose + listen` was rejected: maintaining a keep-alive listener from a GetX controller is an anti-pattern that fights the framework and risks accidental early disposal.

Follows [ADR-0085](./0085-riverpod-state-management-for-local-settings.md): providers are registered on the global `appProviderContainer`.

```dart
// All providers co-located in composer_cache_providers.dart — internal providers are private (_)

final _composerHiveCacheClientProvider =
    Provider<ComposerHiveCacheClient>((_) => ComposerHiveCacheClient());

final _composerCacheDatasourceProvider = Provider<ComposerCacheDatasource>(
  (ref) => ComposerPersistentCacheDatasourceImpl(
    ref.read(_composerHiveCacheClientProvider),
    ref.read(_cacheExceptionThrowerProvider),
  ),
);

final composerCacheRepositoryProvider = Provider<ComposerCacheRepository>(
  (ref) => ComposerCacheRepositoryImpl(ref.read(_composerCacheDatasourceProvider)),
);

final removeAllComposerCacheProvider = Provider<RemoveAllComposerCacheInteractor>(
  (ref) => RemoveAllComposerCacheInteractor(ref.read(composerCacheRepositoryProvider)),
);

final markComposerLocalCacheCleanCloseProvider = Provider<MarkComposerCacheCleanCloseInteractor>(
  (ref) => MarkComposerCacheCleanCloseInteractor(ref.read(composerCacheRepositoryProvider)),
);

final resolveComposerCacheForRestoreProvider = Provider<ResolveComposerCacheForRestoreInteractor>(
  (ref) => ResolveComposerCacheForRestoreInteractor(ref.read(composerCacheRepositoryProvider)),
);

// Keyed by String (autoSaveComposerId). The notifier handles restore/clear; save is
// called directly by HandleMobileAutoSaveExtension via saveComposerCacheInteractor.
final composerAutoSaveProvider = StateNotifierProvider
    .family<ComposerAutoSaveNotifier, ComposerAutoSaveState, String>(
  (ref, composerId) => ComposerAutoSaveNotifier(
    ref.read(resolveComposerCacheForRestoreProvider),
    ref.read(removeAllComposerCacheProvider),
  ),
);
```

`ComposerController` (Android only):

```dart
// _saveSnapshotToCache — calls save interactor directly (not through the notifier)
final createEmailRequest = await buildCreateEmailRequestForAutoSave(
  htmlContent: effectiveContent,  // always pass; never null to avoid a second getText() call
);
await saveComposerCacheInteractor.execute(
  createEmailRequest: createEmailRequest,
  isPersistent: true,
);
notifier.onSnapshotSaved();

// onClose() — invalidate family entry to prevent memory leak on appProviderContainer
appProviderContainer.invalidate(composerAutoSaveProvider(autoSaveComposerId));
```

### Cache eviction

- Entries older than 24 hours are ignored on restore (treated as expired).
- Entries are deleted after successful restoration or after `markCleanClose`.
- On successful server-side draft save (Layer 2), the local cache entry is **not** cleared. Clearing on success introduces a race condition: the periodic 30 s timer may have written a newer snapshot while the JMAP call was in flight on a slow network, and clearing would discard it. Cleanup is handled exclusively by `markCleanClose` (intentional close) and the 24 h TTL.
- If the close is **not** a clean close (system kill, swipe from Recents, or any scenario where `isCleanClose` is not explicitly set to `true`), the entry remains in cache indefinitely until it is either restored by Layer 3/4, replaced by a newer snapshot, or expires after 24 hours. This is intentional: every involuntary kill must result in a restore attempt.
- `composer_hive_cache_box` MUST use encrypted Hive storage (AES-256 cipher) with keys provided by `HiveCacheConfig`. Plaintext storage is not permitted for draft body content. The AES key is generated once by `HiveCacheConfig.initializeEncryptionKey()` on first launch and stored in device secure storage via `EncryptionKeyCacheManager` (backed by `flutter_secure_storage`). There is no scheduled key rotation — the key is stable for the lifetime of the app installation. If the key is missing after a backup/restore (Android backup does not include `flutter_secure_storage` data by default), the Hive box will fail to open; in that case the cache is treated as empty and the user must re-compose.

### What is NOT in scope

- Forwarding `onRenderProcessGone` from `enough_html_editor` to callers — tracked as a separate upstream contribution to that library. The `inactive` snapshot already covers the same scenario because the renderer is always alive at that moment.
- Migrating `ComposerController` from GetX to Riverpod — that is part of the broader ADR-0075 migration roadmap.
- Restoring uploaded attachment binaries — blobs are already on the server; only metadata is needed.
- Restoring in-progress (mid-upload) attachments — attachments without a resolved `blobId` at snapshot time are omitted. The user must re-upload them after restore.

---

## Consequences

### Positive

- Draft content is preserved across Android background kills (both renderer-only and full process), without any user action required. On full process kill (RC2), the composer is automatically re-opened on next app launch.
- Layers 1–4 are **Android-only**. iOS has a less aggressive memory management policy (WKWebView renderer is not independently killable by the OS), so the feature is intentionally scoped to Android to limit complexity.
- The fix is additive — no existing save/close/send logic is changed in behaviour.
- Follows the established Riverpod coexistence pattern (ADR-0085) for the new state logic.
- Layer 2 (silent server save) gives users a fallback in Drafts even if local cache is unavailable.
- The `isCleanClose` discriminant ensures intentional discards are not accidentally restored.
- Cache entries auto-expire after 24 hours — no unbounded Hive growth.

### Negative

- Two `AppLifecycleListener` instances will exist on **Android** per open composer (one already exists in `WebSocketController`). This is acceptable; each is scoped to its owning controller's lifecycle.
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
