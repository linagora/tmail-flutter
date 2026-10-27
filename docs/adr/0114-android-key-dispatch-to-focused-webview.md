# 114. Dispatch Android key events to the focused WebView

Date: 2026-10-21

## Status

Proposed

## Context

- Issue: [#4980][issue].
- The Android composer body is a native `InAppWebView`
  inside the Flutter view.
- On body focus, `ComposerController._onEditorFocusOnMobile`
  unfocuses the Flutter text field, then shows the keyboard.
- Flutter 3.38.9 [`clearTextInputClient`][clear] sets `NO_TARGET`
  but keeps `lastInputConnection`.
- [`handleKeyEvent`][handle] forwards keys to that connection
  without checking `NO_TARGET`.
- The stale Subject [`InputConnectionAdaptor`][adaptor]
  consumes character key-downs.
- Character key-downs from adb and hardware keys never reach the body.
- Key-ups and IME commits (Gboard) still reach the WebView.
- Reproduced on Android 14 / WebView 113; reported on WebView 124.
- Not reproduced on Android 17 / WebView 145.

## Decision

- `MainActivity.dispatchKeyEvent` delegates to `EditorKeyDispatch`,
  which offers each non-system key to `currentFocus` when it is a `WebView` editing text
  (`onCheckIsTextEditor()`).
- Handled by the WebView: dispatch stops; Flutter never sees the key.
- Unhandled, non-WebView or read-only WebView focus, or system keys
  (Back, volume):
  `super.dispatchKeyEvent`.
- The original event is forwarded unchanged
  (key-up, modifiers, repeats).
- No reflection, no private Flutter state, no retained WebView reference.
- `@SuppressLint("RestrictedApi")` is scoped to that method;
  AndroidX marks the inherited public callback restricted.

## Consequences

- Applies to every focused editable WebView, not only the composer.
- Read-only WebViews (email reader) keep normal dispatch,
  so hardware-keyboard navigation still works.
- Workaround for a Flutter engine defect; removable once Flutter
  drops `lastInputConnection` together with the client.
- `WebViewKeyboardTest` (androidTest) covers `EditorKeyDispatch`
  through the debug-only `KeyboardTestActivity`,
  which needs no Flutter engine or Patrol app.
  It runs with every Android Patrol run (local and Firebase Test Lab),
  next to the Dart tests.
- The `MainActivity` delegation is one line and has no test.
- Physical Bluetooth keyboards are not verified.

[issue]: https://github.com/linagora/tmail-flutter/issues/4980
[clear]: https://github.com/flutter/flutter/blob/3.38.9/engine/src/flutter/shell/platform/android/io/flutter/plugin/editing/TextInputPlugin.java#L575
[handle]: https://github.com/flutter/flutter/blob/3.38.9/engine/src/flutter/shell/platform/android/io/flutter/plugin/editing/TextInputPlugin.java#L636
[adaptor]: https://github.com/flutter/flutter/blob/3.38.9/engine/src/flutter/shell/platform/android/io/flutter/plugin/editing/InputConnectionAdaptor.java#L304
