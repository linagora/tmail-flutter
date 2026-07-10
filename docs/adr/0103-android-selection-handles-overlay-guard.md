# 103. Android Selection Handles Overlay Guard

Date: 2026-07-09

## Status

Accepted

## Context

TF-4546: on Android, opening the composer context menu while the editor is focused leaves the WebView's native text-selection handles drawn above the Flutter popup. The handles are rendered by Android WebView in a native layer, so they can overlap the Flutter popup menu. iOS and web do not show the same layering problem.

Root cause: the editor is an Android WebView. When Flutter pushes an overlay route, the WebView keeps text-selection focus, so Android keeps drawing its selection handles even though a Flutter surface is now visually on top.

The fix has to respect these boundaries:
- Android only; iOS/web behavior must stay untouched.
- Target only the currently focused WebView. Other visible WebViews, such as an email viewer behind the composer, must not lose focus.
- Preserve the editor DOM selection/caret when the native focus toggle runs.
- Cover generic dialogs/bottom sheets centrally, but let owner-specific call sites such as the composer menu opt out and own their restore cycle.
- Dispatch composer actions only after the menu closes and native handles are restored, so actions that close the composer do not refocus a disappearing editor.

## Decision

Introduce a reusable selection-handles guard in `core`, a small Android native bridge, and a guarded navigator observer for generic overlay routes.

### Native bridge

Register `AndroidSelectionHandles` from `MainActivity` on the method channel `com.linagora.android.tmail/android_selection_handles` with two methods: `suspend` and `restore`.

`suspend` searches the activity decor view for the visible, focused `WebView`, walking children from topmost to bottommost. If one is found, it stores that exact WebView and calls `onWindowFocusChanged(false)`. This drops the WebView's window focus enough for Android to stop drawing native selection handles, without changing unrelated WebViews.

`restore` only operates on the stored WebView if it is still attached. It calls `requestFocus()` and `onWindowFocusChanged(true)`, then clears the stored reference.

Nested manual guards are reference-counted with `suspendDepth`. If a WebView is already suspended, additional `suspend` calls increment the depth. `restore` decrements until the final restore, and only then returns window focus to the WebView.

### Dart guard

Move the guard from composer-specific code into `core/lib/presentation/utils/`:
- `selection_handles_controller.dart` contains the shared typedefs and `SelectionHandlesController` port.
- `selection_handles_guard.dart` owns the suspend -> action -> restore orchestration and restores in `finally`.
- `android_selection_handles_manager.dart` implements the port through the method channel.
- `selection_handles_overlay_guard.dart` is the cross-platform entry point. It is a no-op off Android and lazily creates the Android manager only when needed.

When an editor JavaScript executor is provided, `AndroidSelectionHandlesManager.suspendSelectionHandles` first runs a script against the editor element (`id="editor"`). The script stores a cloned DOM range in `selectionRange` only when the active element or selected range belongs to the editor. If the editor is not the selection owner, the native channel is not called.

The suspend script deliberately does not blur the editable and does not call `selection.removeAllRanges()`. Blurring/clearing the DOM range hides the handles, but it also removes the visible text highlight while the composer popup is open. The selected text highlight must remain a DOM concern.

On restore, when the caller asks to restore the selection owner focus, the manager runs the restore script and focus callback before and after the native restore, re-applying the stored range so the editor caret survives the focus toggle.

`SelectionHandlesOverlayGuard.clearFlutterSelection` also hides Flutter `SelectableRegion` and `EditableText` toolbars/selections before Android suspension, so Flutter-side selection chrome does not remain over overlays either.

### Guarded route observer

Register `SelectionHandlesRouteObserver` on the app navigator for generic overlays such as dialogs and bottom sheets. It only handles overlay-style routes (`PopupRoute` or otherwise non-opaque routes), not full-screen page navigation. The observer uses native-only suspend/restore and tracks only routes for which its own suspend succeeds, so it restores only the routes it actually affected.

Routes opened while `SelectionHandlesOverlayGuard.protect` is active are skipped by the observer. This keeps the composer popup on the old working path: the manual guard owns the editor JavaScript save/restore cycle and remains the only final restore for that popup. Without this skip, the observer can double-suspend the composer popup and later perform a native-only restore after the manual guard has already tried to restore the editor.

The observer does not call `clearFocus()` and does not mutate the WebView DOM selection. This avoids the email-view regression where closing a dialog could leave text selection disabled.

### Composer menu call site

Keep the composer menu wrapped explicitly with `SelectionHandlesOverlayGuard.protect` because this call site needs behavior beyond generic route coverage:
- Save and restore the editor DOM selection through the rich text editor WebView controller.
- Open the popup with `requestFocus: false` while handles are suspended, so the popup does not pull focus back and re-trigger handles.
- Record the chosen `ComposerActionType` inside the menu item callback, close the menu, then dispatch the action after the guard has restored the native handles.
- Refocus the editor only for actions that keep the composer open (`ComposerActionType.keepsComposerOpen`); actions that close or leave the composer do not.

The previous composer-local manager/guard classes are deleted; core now owns the reusable implementation.

## Consequences

- Android WebView selection handles no longer overlap the composer popup menu.
- Generic dialogs/bottom sheets can hide native handles through the observer without requiring every call site to wrap itself.
- iOS and web run the action directly and never touch JavaScript or the platform channel.
- The focused-WebView search prevents an email viewer WebView from being disturbed when the composer editor is the active selection owner.
- Nested manual guard restore is deterministic because native suspend/restore is depth-counted, and observer routes opened inside manual guards are skipped.
- Composer action timing is safer: user actions run after the popup closes and after handles are restored.

## Risks

- The JavaScript selection preservation is tied to the editor element id `editor`. If the editor DOM changes that id, guarded composer suspension will fall back to unguarded behavior.
- A generic observer route has no editor JavaScript restore. Owner-specific overlays must still use `SelectionHandlesOverlayGuard.protect` when they need DOM selection restoration.
- The native workaround relies on `WebView.onWindowFocusChanged`; Android WebView internals can change, so this should be manually regression-tested on representative Android versions and OEMs.

## Verification

- Unit tests cover `SelectionHandlesGuard` orchestration, Android manager platform-channel behavior, Android/non-Android overlay guard behavior, and route observer skip/restore behavior.
- Manual Android verification should cover composer menu open/dismiss, generic dialog/bottom-sheet overlap while text is selected, and email-view selection after closing dialogs.
