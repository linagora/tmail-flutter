import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart' show TestFailure;
import 'package:tmail_ui_user/features/base/base_controller.dart';

import 'test_timeouts.dart';

/// What a [waitForViewState] call is waiting for: the success meaning the action
/// landed, the failures meaning it failed, and a name to report both under.
///
/// [failureMatcher] declares which failures mean *this* action failed. Those
/// abort the wait immediately, so a rejected save reports in seconds instead of
/// burning the whole timeout to report a timeout it already knew the answer to.
///
/// Match narrowly — name the failures your action produces, nothing else.
/// `MailboxDashBoardController` in particular is a shared bus: vacation fetch,
/// mark-as-read, token refresh and others all push onto the same `viewState`,
/// so a broad [failureMatcher] lets unrelated background work fail an otherwise
/// healthy test. Unmatched failures are not fatal; they are collected and
/// reported if the wait times out.
class ViewStateExpectation {
  final bool Function(Success state) matcher;
  final bool Function(Failure state) failureMatcher;
  final String description;

  const ViewStateExpectation({
    required this.matcher,
    required this.failureMatcher,
    required this.description,
  });
}

/// Waits for a view state on [controller] matching [expectation].
///
/// Call this *before* firing the action that produces the state, then await the
/// returned future afterwards:
///
/// ```dart
/// final saved = waitForViewState(
///   Get.find<MailboxDashBoardController>(),
///   ViewStateExpectation(
///     matcher: (state) => state is UpdateEmailDraftsSuccess,
///     failureMatcher: (state) => state is UpdateEmailDraftsFailure,
///     description: 'UpdateEmailDraftsSuccess',
///   ),
/// );
/// await composerRobot.tapSaveAsDraftButton();
/// await saved;
/// ```
///
/// Subscribing up front is what makes this reliable. States are momentary: by
/// the time an action has been tapped and the tree pumped, the state has often
/// already been emitted and replaced. Anything that samples after the fact
/// (polling for a toast, reading `viewState.value`) races that window and loses
/// on slow devices. A subscription cannot miss an event it is already listening
/// for, however long the action takes.
///
/// Prefer this over asserting on a toast. Toasts self-dismiss on a timer and
/// are skipped entirely when there is no overlay context, so a missing toast
/// cannot distinguish "the action failed" from "the action worked but the toast
/// was gone or never rendered".
Future<Success> waitForViewState(
  BaseController controller,
  ViewStateExpectation expectation, {
  Duration timeout = TestTimeouts.long,
}) {
  final completer = Completer<Success>();
  final failuresSeen = <Failure>[];
  late final StreamSubscription<Either<Failure, Success>> subscription;

  subscription = controller.viewState.stream.listen((state) {
    state.fold(
      (failure) {
        if (!expectation.failureMatcher(failure)) {
          failuresSeen.add(failure);
          return;
        }
        if (!completer.isCompleted) {
          completer.completeError(TestFailure(
            'waitForViewState: ${controller.runtimeType} emitted $failure '
            'while waiting for ${expectation.description}',
          ));
        }
      },
      (success) {
        if (!completer.isCompleted && expectation.matcher(success)) {
          completer.complete(success);
        }
      },
    );
  });

  final result = completer.future.timeout(
    timeout,
    onTimeout: () => throw TimeoutException(
      'waitForViewState: no ${expectation.description} emitted by '
      '${controller.runtimeType} within ${timeout.inSeconds}s.\n'
      '${_describeFailures(failuresSeen)}',
      timeout,
    ),
  ).whenComplete(subscription.cancel);

  // Callers await this only *after* firing the action, so a failure arriving
  // mid-action would land on a future with no listener yet and be reported as
  // an unhandled async error, crashing the run instead of failing the test.
  // Marking it ignored suppresses that; the pending await still receives it.
  result.ignore();

  return result;
}

/// Anything reaching here was rejected by [ViewStateExpectation.failureMatcher],
/// so it is not the cause — but printing it still beats a timeout that says only
/// that nothing arrived.
String _describeFailures(List<Failure> failures) {
  if (failures.isEmpty) {
    return 'No failure state was emitted either — the action likely never '
        'reached the controller.';
  }
  return 'Unmatched failures emitted while waiting (background work on this '
      'shared bus, not the awaited action — unless the matcher is too narrow):\n'
      '${failures.map((failure) => '  - $failure').join('\n')}';
}
