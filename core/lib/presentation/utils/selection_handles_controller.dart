/// Contracts shared by the selection-handles guard and its platform managers.

typedef EvaluateSelectionJavascript =
    Future<dynamic> Function({required String source});

typedef FocusSelectionOwnerCallback = Future<void> Function();

typedef GuardedSelectionHandlesAction<T> = Future<T> Function(bool suspended);

typedef RestoreSelectionOwnerFocusDecision<T> = bool Function(T result);

abstract interface class SelectionHandlesController {
  Future<bool> suspendSelectionHandles({
    required EvaluateSelectionJavascript? evaluateJavascript,
  });

  Future<void> restoreSelectionHandles({
    required bool restoreSelectionOwnerFocus,
    required EvaluateSelectionJavascript? evaluateJavascript,
    required FocusSelectionOwnerCallback? focusSelectionOwner,
  });
}
