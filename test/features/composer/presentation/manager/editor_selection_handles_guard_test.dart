import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/android_editor_selection_handles_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/editor_selection_handles_guard.dart';

/// Records the calls made by the guard and controls whether suspension happens,
/// so the orchestration can be tested without any platform channel.
class _FakeSelectionHandlesController
    implements EditorSelectionHandlesController {
  _FakeSelectionHandlesController({required this.suspendResult});

  final bool suspendResult;
  final List<String> calls = [];
  bool? restoredWithFocus;

  @override
  Future<bool> suspendSelectionHandles({
    required EvaluateEditorJavascript? evaluateJavascript,
  }) async {
    calls.add('suspend');
    return suspendResult;
  }

  @override
  Future<void> restoreSelectionHandles({
    required bool restoreEditorFocus,
    required EvaluateEditorJavascript? evaluateJavascript,
    required FocusEditorCallback? focusEditor,
  }) async {
    calls.add('restore');
    restoredWithFocus = restoreEditorFocus;
  }
}

void main() {
  group('EditorSelectionHandlesGuard::protect', () {
    test('suspends, runs the action, then restores in order', () async {
      final controller = _FakeSelectionHandlesController(suspendResult: true);
      final guard = EditorSelectionHandlesGuard(controller);
      bool? suspendedFlagSeenByAction;

      await guard.protect(
        evaluateJavascript: null,
        focusEditor: null,
        action: (suspended) async {
          suspendedFlagSeenByAction = suspended;
          controller.calls.add('action');
          return true;
        },
      );

      expect(suspendedFlagSeenByAction, isTrue);
      expect(controller.calls, ['suspend', 'action', 'restore']);
    });

    test('restores with the focus decision returned by the action', () async {
      final controller = _FakeSelectionHandlesController(suspendResult: true);
      final guard = EditorSelectionHandlesGuard(controller);

      await guard.protect(
        evaluateJavascript: null,
        focusEditor: null,
        action: (_) async => false,
      );

      expect(controller.restoredWithFocus, isFalse);
    });

    test('runs the action unguarded when suspension does not happen', () async {
      final controller = _FakeSelectionHandlesController(suspendResult: false);
      final guard = EditorSelectionHandlesGuard(controller);
      bool? suspendedFlagSeenByAction;

      await guard.protect(
        evaluateJavascript: null,
        focusEditor: null,
        action: (suspended) async {
          suspendedFlagSeenByAction = suspended;
          controller.calls.add('action');
          return true;
        },
      );

      expect(suspendedFlagSeenByAction, isFalse);
      expect(controller.calls, ['suspend', 'action']);
      expect(controller.restoredWithFocus, isNull);
    });

    test(
      'restores without editor focus and rethrows when the action throws',
      () async {
        final controller = _FakeSelectionHandlesController(suspendResult: true);
        final guard = EditorSelectionHandlesGuard(controller);

        await expectLater(
          guard.protect(
            evaluateJavascript: null,
            focusEditor: null,
            action: (_) async => throw StateError('boom'),
          ),
          throwsStateError,
        );

        expect(controller.calls, ['suspend', 'restore']);
        expect(controller.restoredWithFocus, isFalse);
      },
    );
  });
}
