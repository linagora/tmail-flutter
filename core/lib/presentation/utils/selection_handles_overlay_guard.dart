import 'package:core/presentation/utils/android_selection_handles_manager.dart';
import 'package:core/presentation/utils/selection_handles_controller.dart';
import 'package:core/presentation/utils/selection_handles_guard.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';

/// Cross-platform entry point for showing an overlay (menu, dialog, popup,
/// bottom sheet) without the platform text selection handles overlapping it.
///
/// On platforms where selection handles do not overlap overlays this is a
/// no-op and simply runs [action]. The suspend/restore is only implemented for
/// the platform that needs it, currently via [AndroidSelectionHandlesManager].
class SelectionHandlesOverlayGuard {
  SelectionHandlesOverlayGuard._();

  static AndroidSelectionHandlesManager? _manager;
  static int _activeProtectDepth = 0;

  static AndroidSelectionHandlesManager get _sharedManager =>
      _manager ??= AndroidSelectionHandlesManager();

  static Future<T> protect<T>({
    required GuardedSelectionHandlesAction<T> action,
    BuildContext? context,
    EvaluateSelectionJavascript? evaluateJavascript,
    FocusSelectionOwnerCallback? focusSelectionOwner,
    RestoreSelectionOwnerFocusDecision<T>? restoreSelectionOwnerFocus,
  }) async {
    if (!PlatformInfo.isAndroid) {
      return action(false);
    }

    _activeProtectDepth += 1;
    try {
      clearFlutterSelection(context);

      return await SelectionHandlesGuard(_sharedManager).protect(
        action: action,
        evaluateJavascript: evaluateJavascript,
        focusSelectionOwner: focusSelectionOwner,
        restoreSelectionOwnerFocus: restoreSelectionOwnerFocus,
      );
    } finally {
      _activeProtectDepth -= 1;
    }
  }

  /// Fire-and-forget entry used by [SelectionHandlesRouteObserver] for generic
  /// overlays that do not have owner-specific restore callbacks. Routes opened
  /// inside [protect] are skipped so the manual guard remains the only owner of
  /// composer editor selection save/restore.
  static Future<bool> suspend({BuildContext? context}) {
    if (!PlatformInfo.isAndroid || _activeProtectDepth > 0) {
      return Future<bool>.value(false);
    }
    clearFlutterSelection(context);
    return _sharedManager.suspendSelectionHandles(evaluateJavascript: null);
  }

  /// Restores the native selection handles suspended by [suspend].
  static Future<void> restore() {
    if (!PlatformInfo.isAndroid) {
      return Future<void>.value();
    }
    return _sharedManager.restoreSelectionHandles(
      restoreSelectionOwnerFocus: false,
      evaluateJavascript: null,
      focusSelectionOwner: null,
    );
  }

  @visibleForTesting
  static bool clearFlutterSelection(BuildContext? context) {
    var clearedSelection = false;

    if (context?.mounted == true) {
      clearedSelection = _clearSelectableRegion(context!) || clearedSelection;
    }

    final focusContext = FocusManager.instance.primaryFocus?.context;
    if (focusContext != null) {
      clearedSelection =
          _clearSelectableRegion(focusContext) || clearedSelection;
    }

    final editableTextState = focusContext
        ?.findAncestorStateOfType<EditableTextState>();
    if (editableTextState != null) {
      editableTextState.hideToolbar();
      FocusManager.instance.primaryFocus?.unfocus();
      clearedSelection = true;
    }

    return clearedSelection;
  }

  static bool _clearSelectableRegion(BuildContext context) {
    final selectableRegion = context
        .findAncestorStateOfType<SelectableRegionState>();
    if (selectableRegion == null) {
      return false;
    }

    selectableRegion.hideToolbar();
    selectableRegion.clearSelection();
    FocusManager.instance.primaryFocus?.unfocus();
    return true;
  }
}
