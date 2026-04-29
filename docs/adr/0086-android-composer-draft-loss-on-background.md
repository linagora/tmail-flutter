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

Add an `AppLifecycleListener` to `ComposerController` (mobile only). On `onInactive`, extract the editor HTML and all composer fields (recipients, subject, identity, attachments metadata), then persist them to a new Hive box (`composerMobileCache`) keyed by `_mobileSessionId`.

> **`composerId`** is a web-only concept managed by `ComposerManager` to support multiple simultaneous composer instances on desktop browsers. On mobile, `ComposerBindings` is always instantiated without a `composerId` (it is `null`). Therefore, the mobile cache uses a separate **`_mobileSessionId`**: a UUID generated by `UuidGenerator` inside `ComposerController.onInit()` exclusively on mobile. Since mobile allows only one composer at a time (full-screen route), a single UUID per session is sufficient as the cache key.

This is the primary fix for both RC1 and RC2. It is fast, offline, and does not depend on network connectivity.

**Fallback for `getText()` failure**: a periodic content snapshot (`Timer.periodic(30s)`) runs while the editor is loaded, storing the last known HTML in `_lastKnownContent`. If `getText()` times out (> 2 s) at `inactive`, the snapshot is used.

**System dialog false positive**: `AppLifecycleState.inactive` is also triggered by system overlays (permission dialogs, incoming calls, notification shade). To avoid unnecessary saves in these cases, the save is preceded by a short guard delay (~300 ms). If the state returns to `active` within that window, the save is cancelled. This prevents redundant Hive writes and network calls when the user never actually leaves the app.

**In-progress attachment uploads**: if the user backgrounds the app while an attachment is still uploading, that attachment will not yet have a `blobId`. Only completed attachments (with a resolved `blobId`) are included in `SavedComposerSnapshot`. In-progress attachments are omitted and must be re-uploaded after restore. This is a known limitation documented in the Negative consequences.

#### Layer 2 — Silent Server-Side Draft Save at `AppLifecycleState.inactive`

After Layer 1 completes (still within `onInactive`), trigger `CreateNewAndSaveEmailToDraftsInteractor` silently in the background (best-effort, no UI feedback, no dialog). This saves the draft to the JMAP server, protecting against RC2 even if the local cache is later lost (e.g. app data cleared).

**Why `inactive` and not `paused`**: at `AppLifecycleState.paused`, Android Doze mode and app-standby buckets may throttle or block outbound network traffic before the request completes. `inactive` is before the compositor is frozen, giving the network call the best chance of completing while the renderer is still alive.

This is **fire-and-forget** — failure is logged to console and reported as a Sentry breadcrumb (severity: info) for monitoring purposes, but not surfaced to the user. The draft will appear in the Drafts folder on success.

**Deduplication guard**: a boolean `_isSavingToDraftInProgress` flag on `ComposerController` ensures only one server-side save runs at a time. If `onInactive` fires again (e.g., user rapidly switches apps back and forth) while a save is still in flight, the duplicate trigger is silently skipped. The flag is cleared on completion (success or failure).

#### Layer 3 — Recovery at `AppLifecycleState.resumed` / `onReady` (RC1)

On `ComposerController.onReady()` (mobile only), check whether a non-clean-close cache entry exists for the current `_mobileSessionId`. If found, inject the cached HTML into the editor and restore all composer fields. Delete the cache entry after successful restoration.

On `AppLifecycleState.resumed`, check if the editor is blank (renderer was killed while app stayed alive) and a non-clean cache entry exists. If so, reinject the cached content.

#### Layer 4 — Re-open Composer on App Restart (RC2)

When Android kills the entire app process, `ComposerController` is destroyed along with the route stack. `_onAppRestart()` inside `ComposerController` will never be called because the controller no longer exists.

Recovery for RC2 must happen at a higher level — `MailboxDashBoardController.onReady()` — which always runs when the app restarts. On startup:

1. `MailboxDashBoardController` reads all non-clean-close entries from `ComposerMobileCacheClient`.
2. If one or more valid entries exist (age < 24 h, `isCleanClose = false`), the dashboard automatically opens the composer with the cached snapshot passed as `ComposerArguments`.
3. `ComposerController.onReady()` then proceeds with Layer 3 to inject the content into the editor.
4. The cache entry is cleared after successful restoration.

```text
App process restarted
        │
        ▼
MailboxDashBoardController.onReady()
        │
        ├── composerAutoSaveProvider.restore()  ← check all cache entries
        │
        ├── entries found? → openComposer(ComposerArguments.fromSnapshot(snapshot))
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
ComposerController (GetX)
    │
    ├── AppLifecycleListener
    │       ├── onInactive → _onAppInactive()
    │       └── onRestart  → _onAppRestart()
    │
    ├── _onAppInactive()
    │       ├── content = await getContentInEditor().timeout(2s) ?? _lastKnownContent
    │       └── appProviderContainer.read(composerAutoSaveProvider.notifier)
    │                   .saveLocally(_mobileSessionId, content, recipients, subject, ...)
    │
    ├── onReady() [RC1 recovery]
    │       └── _checkAndRestoreComposerCache()
    │
    └── _closeComposerAction() [mark clean]
            └── appProviderContainer.read(composerAutoSaveProvider.notifier)
                        .markCleanClose(_mobileSessionId)
```

```text
ComposerAutoSaveNotifier (Riverpod StateNotifier)
    │
    ├── saveLocally(mobileSessionId, SavedComposerSnapshot)
    │       └── ComposerMobileCacheClient.insertItem(key, json)
    │
    ├── restore(mobileSessionId) → SavedComposerSnapshot?
    │       └── ComposerMobileCacheClient.getItem(key)
    │           filters: isCleanClose = false, age < 24h
    │
    ├── markCleanClose(mobileSessionId)
    │       └── ComposerMobileCacheClient.updateItem(key, json with isCleanClose=true)
    │
    └── clearCache(mobileSessionId)
            └── ComposerMobileCacheClient.deleteItem(key)
```

### New `SavedComposerSnapshot` model

A lightweight Hive-storable model (stored as JSON string via `HiveCacheClient<String>`):

```dart
class SavedComposerSnapshot {
  final String mobileSessionId;  // mobile-only UUID; not the web composerId
  final String emailContent;     // raw HTML
  final String subject;
  final List<String> toRecipients;    // JSON-serialized EmailAddress list
  final List<String> ccRecipients;
  final List<String> bccRecipients;
  final List<String> replyToRecipients;
  final String? identityJson;
  final List<String> attachments; // serialized Attachment list (metadata only)
  final bool hasReadReceipt;
  final bool isMarkAsImportant;
  final bool isCleanClose;
  final int timestampMs;
  final String? draftEmailId;     // null if new compose
  final String emailActionType;   // EmailActionType.name
}
```

Attachments store only metadata (name, size, blobId) — not the binary content. This is sufficient to reconstruct the `CreateEmailRequest` on restore since the blobs are already on the server.

### Riverpod pattern

`ComposerAutoSaveNotifier` (Riverpod `StateNotifier`) owns all cache read/write logic: `saveLocally`, `restore`, `markCleanClose`, and `clearCache`. Riverpod is chosen here — rather than adding more state directly to `ComposerController` — to keep the auto-save concern isolated, independently testable, and aligned with the ADR-0075 migration roadmap. `ComposerController` (GetX) is a consumer only, via `appProviderContainer.read(...)`.

Follows [ADR-0085](./0085-riverpod-state-management-for-local-settings.md): a `StateNotifierProvider` exposed on the global `appProviderContainer`. `ComposerController` (GetX) consumes it via `appProviderContainer.read(...)`, maintaining the established coexistence pattern.

```dart
final composerAutoSaveProvider =
    StateNotifierProvider<ComposerAutoSaveNotifier, ComposerAutoSaveState>(
  (ref) => ComposerAutoSaveNotifier(ComposerMobileCacheClient()),
);
```

### Files introduced

| File | Role |
|---|---|
| `lib/features/caching/clients/composer_mobile_cache_client.dart` | `HiveCacheClient<String>` for the new Hive box |
| `lib/features/composer/presentation/model/saved_composer_snapshot.dart` | Lightweight cache model |
| `lib/features/composer/presentation/providers/composer_auto_save_notifier.dart` | Riverpod `StateNotifier` + provider |
| `lib/features/composer/presentation/extensions/handle_mobile_auto_save_extension.dart` | Extension on `ComposerController` |

### Files modified

| File | Change |
|---|---|
| `lib/features/composer/presentation/composer_controller.dart` | Add `AppLifecycleListener`, periodic snapshot timer, `_lastKnownContent` |
| `lib/features/composer/presentation/composer_bindings.dart` | Register `ComposerMobileCacheClient` |
| `lib/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart` | Add RC2 recovery check in `onReady()` — reads cache and auto-opens composer |

### Cache eviction

- Entries older than 24 hours are ignored on restore (treated as expired).
- Entries are deleted after successful restoration or after `markCleanClose`.
- On successful server-side draft save (Layer 2), the local cache entry is also cleared.
- If the close is **not** a clean close (system kill, swipe from Recents, or any scenario where `isCleanClose` is not explicitly set to `true`), the entry remains in cache indefinitely until it is either restored by Layer 3/4, replaced by a newer snapshot, or expires after 24 hours. This is intentional: every involuntary kill must result in a restore attempt.
- `composerMobileCache` MUST use encrypted Hive storage (AES-256 cipher) with keys provided by `HiveCacheConfig`. Plaintext storage is not permitted for draft body content. Key rotation follows the same policy as other sensitive Hive boxes in the app.

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
- Attachments that are still uploading when the user backgrounds the app will not be included in `SavedComposerSnapshot` (no `blobId` yet). These must be re-uploaded after restore. This is a known limitation.

## References

- [TF-4473 — Android app crash when composing and app goes in background](https://github.com/linagora/tmail-flutter/issues/4473)
- [flutter_inappwebview `onRenderProcessGone` source](https://github.com/pichillilorenzo/flutter_inappwebview/blob/master/flutter_inappwebview/lib/src/in_app_webview/in_app_webview.dart) — available from Android 26+ (Android 8.0); previously `androidOnRenderProcessGone`, unified and renamed in v6.x
- [Android `WebViewClient.onRenderProcessGone` official docs](https://developer.android.com/reference/android/webkit/WebViewClient#onRenderProcessGone(android.webkit.WebView,android.webkit.RenderProcessGoneDetail))
- [enough_html_editor source — `_buildEditor()` without `onRenderProcessGone`](https://github.com/linagora/enough_html_editor)
- [Android OOM killer / lowmemorykiller](https://source.android.com/devices/tech/perf/lmkd)
