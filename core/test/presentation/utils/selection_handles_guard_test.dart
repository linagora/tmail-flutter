import 'package:core/presentation/utils/selection_handles_controller.dart';
import 'package:core/presentation/utils/selection_handles_guard.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the calls made by the guard and controls whether suspension happens,
/// so the orchestration can be tested without any platform channel.
class _FakeSelectionHandlesController implements SelectionHandlesController {
  _FakeSelectionHandlesController({required this.suspendResult});

  final bool suspendResult;
  final List<String> calls = [];
  bool? restoredWithFocus;

  @override
  Future<bool> suspendSelectionHandles({
    required EvaluateSelectionJavascript? evaluateJavascript,
  }) async {
    calls.add('suspend');
    return suspendResult;
  }

  @override
  Future<void> restoreSelectionHandles({
    required bool restoreSelectionOwnerFocus,
    required EvaluateSelectionJavascript? evaluateJavascript,
    required FocusSelectionOwnerCallback? focusSelectionOwner,
  }) async {
    calls.add('restore');
    restoredWithFocus = restoreSelectionOwnerFocus;
  }
}

void main() {
  group('SelectionHandlesGuard::protect', () {
    test('suspends, runs the action, then restores in order', () async {
      final controller = _FakeSelectionHandlesController(suspendResult: true);
      final guard = SelectionHandlesGuard(controller);
      bool? suspendedFlagSeenByAction;

      await guard.protect<bool>(
        action: (suspended) async {
          suspendedFlagSeenByAction = suspended;
          controller.calls.add('action');
          return true;
        },
      );

      expect(suspendedFlagSeenByAction, isTrue);
      expect(controller.calls, ['suspend', 'action', 'restore']);
    });

    test('restores with the focus decision derived from the result', () async {
      final controller = _FakeSelectionHandlesController(suspendResult: true);
      final guard = SelectionHandlesGuard(controller);

      await guard.protect<bool>(
        restoreSelectionOwnerFocus: (result) => result,
        action: (_) async => false,
      );

      expect(controller.restoredWithFocus, isFalse);
    });

    test('runs the action unguarded when suspension does not happen', () async {
      final controller = _FakeSelectionHandlesController(suspendResult: false);
      final guard = SelectionHandlesGuard(controller);
      bool? suspendedFlagSeenByAction;

      await guard.protect<bool>(
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
      'restores without owner focus and rethrows when the action throws',
      () async {
        final controller = _FakeSelectionHandlesController(suspendResult: true);
        final guard = SelectionHandlesGuard(controller);

        await expectLater(
          guard.protect<bool>(
            restoreSelectionOwnerFocus: (result) => result,
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
