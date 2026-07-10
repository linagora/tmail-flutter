import 'package:core/presentation/utils/selection_handles_controller.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidSelectionHandlesManager implements SelectionHandlesController {
  AndroidSelectionHandlesManager({
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
    window.selectionRange = undefined;
    return isEditorActive;
  }

  const range = selection.getRangeAt(0);
  if (!editor.contains(range.commonAncestorContainer)) {
    window.selectionRange = undefined;
    return isEditorActive;
  }

  window.selectionRange = range.cloneRange();
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

    if (window.selectionRange === undefined) {
      return true;
    }

    const selection = document.getSelection();
    if (!selection) {
      return false;
    }

    selection.removeAllRanges();
    selection.addRange(window.selectionRange.cloneRange());
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
    required EvaluateSelectionJavascript? evaluateJavascript,
  }) async {
    if (!PlatformInfo.isAndroid) {
      return false;
    }

    try {
      if (evaluateJavascript != null) {
        final shouldSuspendHandles = await evaluateJavascript(
          source: storeSelectionRangeScript,
        );
        if (!_isTrue(shouldSuspendHandles)) {
          return false;
        }
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
    required bool restoreSelectionOwnerFocus,
    required EvaluateSelectionJavascript? evaluateJavascript,
    required FocusSelectionOwnerCallback? focusSelectionOwner,
  }) async {
    if (!PlatformInfo.isAndroid) {
      return;
    }

    try {
      if (restoreSelectionOwnerFocus) {
        // Pre-restore: set up the DOM selection so native handles appear
        // in the correct position when re-enabled.
        await _restoreSelectionOwnerSelection(
          evaluateJavascript: evaluateJavascript,
          focusSelectionOwner: focusSelectionOwner,
        );
      }

      await _channel.invokeMethod<bool>(restoreMethod);

      if (restoreSelectionOwnerFocus) {
        // Post-restore: re-apply the selection after native handles are
        // back, since the native restore may reset focus/selection state.
        await _restoreSelectionOwnerSelection(
          evaluateJavascript: evaluateJavascript,
          focusSelectionOwner: focusSelectionOwner,
        );
      }
    } catch (exception) {
      logWarning(
        '$runtimeType::restoreSelectionHandles:Exception = $exception',
      );
    }
  }

  Future<void> _restoreSelectionOwnerSelection({
    required EvaluateSelectionJavascript? evaluateJavascript,
    required FocusSelectionOwnerCallback? focusSelectionOwner,
  }) async {
    await evaluateJavascript?.call(source: restoreSelectionRangeScript);
    await focusSelectionOwner?.call();
  }

  bool _isTrue(dynamic value) =>
      value == true || value?.toString() == trueValue;
}
