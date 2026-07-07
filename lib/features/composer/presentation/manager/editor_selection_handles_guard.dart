import 'package:tmail_ui_user/features/composer/presentation/manager/android_editor_selection_handles_manager.dart';

/// Runs while handles are suspended; gets whether suspension happened and
/// returns whether the editor should refocus during restore.
typedef GuardedSelectionHandlesAction =
    Future<bool> Function(bool suspended);

/// Wraps a UI action in a suspend → run → restore of the editor selection
/// handles, so any overlapping overlay reuses one tested flow.
class EditorSelectionHandlesGuard {
  const EditorSelectionHandlesGuard(this._controller);

  final EditorSelectionHandlesController _controller;

  /// Suspends handles, runs [action], then restores them. If suspension is
  /// skipped [action] just runs; if it throws, handles restore without refocus.
  Future<void> protect({
    required EvaluateEditorJavascript? evaluateJavascript,
    required FocusEditorCallback? focusEditor,
    required GuardedSelectionHandlesAction action,
  }) async {
    final suspended = await _controller.suspendSelectionHandles(
      evaluateJavascript: evaluateJavascript,
    );

    if (!suspended) {
      await action(false);
      return;
    }

    var restoreEditorFocus = false;
    try {
      restoreEditorFocus = await action(true);
    } finally {
      await _controller.restoreSelectionHandles(
        restoreEditorFocus: restoreEditorFocus,
        evaluateJavascript: evaluateJavascript,
        focusEditor: focusEditor,
      );
    }
  }
}
