import 'package:core/presentation/utils/selection_handles_controller.dart';

/// Runs an action while a [SelectionHandlesController] keeps the platform text
/// selection handles suspended, then restores them. This is the reusable
/// mechanism; overlay call sites should use the overlay guard entry point.
class SelectionHandlesGuard {
  const SelectionHandlesGuard(this._controller);

  final SelectionHandlesController _controller;

  Future<T> protect<T>({
    required GuardedSelectionHandlesAction<T> action,
    EvaluateSelectionJavascript? evaluateJavascript,
    FocusSelectionOwnerCallback? focusSelectionOwner,
    RestoreSelectionOwnerFocusDecision<T>? restoreSelectionOwnerFocus,
  }) async {
    final suspended = await _controller.suspendSelectionHandles(
      evaluateJavascript: evaluateJavascript,
    );

    if (!suspended) {
      return action(false);
    }

    var shouldRestoreSelectionOwnerFocus = false;
    try {
      final result = await action(true);
      shouldRestoreSelectionOwnerFocus =
          restoreSelectionOwnerFocus?.call(result) ?? false;
      return result;
    } finally {
      await _controller.restoreSelectionHandles(
        restoreSelectionOwnerFocus: shouldRestoreSelectionOwnerFocus,
        evaluateJavascript: evaluateJavascript,
        focusSelectionOwner: focusSelectionOwner,
      );
    }
  }
}
