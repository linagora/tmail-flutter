import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef EvaluateEditorJavascript =
    Future<dynamic> Function({required String source});

typedef FocusEditorCallback = Future<void> Function();

/// Suspends and restores the editor text-selection handles, behind a seam the
/// guard can substitute or fake.
abstract interface class EditorSelectionHandlesController {
  Future<bool> suspendSelectionHandles({
    required EvaluateEditorJavascript? evaluateJavascript,
  });

  Future<void> restoreSelectionHandles({
    required bool restoreEditorFocus,
    required EvaluateEditorJavascript? evaluateJavascript,
    required FocusEditorCallback? focusEditor,
  });
}

class AndroidEditorSelectionHandlesManager
    implements EditorSelectionHandlesController {
  // Non-const so callers can build it lazily and skip it entirely off-Android.
  AndroidEditorSelectionHandlesManager({
    MethodChannel channel = const MethodChannel(channelName),
  }) : _channel = channel;

  @visibleForTesting
  static const String channelName =
      'com.linagora.android.tmail/android_selection_handles';
  @visibleForTesting
  static const String suspendMethod = 'suspend';
  @visibleForTesting
  static const String restoreMethod = 'restore';
  @visibleForTesting
  static const String editorElementId = 'editor';
  @visibleForTesting
  static const String trueValue = 'true';

  @visibleForTesting
  static const String storeSelectionRangeScript =
      '''
(() => {
  const editor = document.getElementById('$editorElementId');
  if (!editor) {
    return false;
  }

  const selection = document.getSelection();
  const activeElement = document.activeElement;
  const isEditorActive = activeElement === editor ||
      editor.contains(activeElement);
  if (!selection || selection.rangeCount === 0) {
    selectionRange = undefined;
    return isEditorActive;
  }

  const range = selection.getRangeAt(0);
  if (!editor.contains(range.commonAncestorContainer)) {
    selectionRange = undefined;
    return isEditorActive;
  }

  selectionRange = range.cloneRange();
  return true;
})();''';

  @visibleForTesting
  static const String restoreSelectionRangeScript =
      '''
(() => {
  const editor = document.getElementById('$editorElementId');
  if (!editor) {
    return false;
  }

  const restore = () => {
    if (typeof editor.focus === 'function') {
      editor.focus({ preventScroll: true });
    }

    if (selectionRange === undefined) {
      return true;
    }

    const selection = document.getSelection();
    if (!selection) {
      return false;
    }

    selection.removeAllRanges();
    selection.addRange(selectionRange.cloneRange());
    return true;
  };

  restore();
  if (typeof requestAnimationFrame === 'function') {
    requestAnimationFrame(restore);
  }
  return true;
})();''';

  final MethodChannel _channel;

  @override
  Future<bool> suspendSelectionHandles({
    required EvaluateEditorJavascript? evaluateJavascript,
  }) async {
    // Android-only issue: never touch the editor or native bridge elsewhere.
    if (!PlatformInfo.isAndroid || evaluateJavascript == null) {
      return false;
    }

    try {
      final shouldSuspendHandles = await evaluateJavascript(
        source: storeSelectionRangeScript,
      );
      if (!_isTrue(shouldSuspendHandles)) {
        return false;
      }

      final hasSuspendedNativeHandles = await _channel.invokeMethod<bool>(
        suspendMethod,
      );
      return hasSuspendedNativeHandles == true;
    } catch (exception) {
      logWarning(
        '$runtimeType::suspendSelectionHandles:Exception = $exception',
      );
      return false;
    }
  }

  @override
  Future<void> restoreSelectionHandles({
    required bool restoreEditorFocus,
    required EvaluateEditorJavascript? evaluateJavascript,
    required FocusEditorCallback? focusEditor,
  }) async {
    if (!PlatformInfo.isAndroid) {
      return;
    }

    try {
      // Restore around the native focus toggle: the WebView drops the caret
      // when it regains focus, so re-apply it both before and after.
      if (restoreEditorFocus) {
        await _restoreEditorSelection(
          evaluateJavascript: evaluateJavascript,
          focusEditor: focusEditor,
        );
      }

      await _channel.invokeMethod<bool>(restoreMethod);

      if (restoreEditorFocus) {
        await _restoreEditorSelection(
          evaluateJavascript: evaluateJavascript,
          focusEditor: focusEditor,
        );
      }
    } catch (exception) {
      logWarning(
        '$runtimeType::restoreSelectionHandles:Exception = $exception',
      );
    }
  }

  Future<void> _restoreEditorSelection({
    required EvaluateEditorJavascript? evaluateJavascript,
    required FocusEditorCallback? focusEditor,
  }) async {
    await evaluateJavascript?.call(source: restoreSelectionRangeScript);
    await focusEditor?.call();
  }

  bool _isTrue(dynamic value) =>
      value == true || value?.toString() == trueValue;
}
