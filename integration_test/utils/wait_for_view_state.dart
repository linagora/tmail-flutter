import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';

import 'test_timeouts.dart';

/// Waits for a controller view state matching [matcher].
///
/// Call this *before* firing the action that produces the state, then await the
/// returned future afterwards:
///
/// ```dart
/// final saved = waitForViewState(
///   Get.find<MailboxDashBoardController>(),
///   matcher: (state) => state is UpdateEmailDraftsSuccess,
///   description: 'UpdateEmailDraftsSuccess',
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
///
/// Deliberately never completes on a [Failure]. `MailboxDashBoardController` in
/// particular is a shared bus — vacation fetch, mark-as-read, token refresh and
/// others all push onto the same `viewState` — so aborting on any failure would
/// let unrelated background work fail an otherwise healthy test. Failures are
/// instead collected and reported in the timeout message.
Future<Success> waitForViewState(
  BaseController controller, {
  required bool Function(Success state) matcher,
  required String description,
  Duration timeout = TestTimeouts.long,
}) {
  final completer = Completer<Success>();
  final failuresSeen = <Failure>[];
  late final StreamSubscription<Either<Failure, Success>> subscription;

  subscription = controller.viewState.stream.listen((state) {
    state.fold(
      failuresSeen.add,
      (success) {
        if (!completer.isCompleted && matcher(success)) {
          completer.complete(success);
        }
      },
    );
  });

  return completer.future.timeout(
    timeout,
    onTimeout: () => throw TimeoutException(
      'waitForViewState: no $description emitted by ${controller.runtimeType} '
      'within ${timeout.inSeconds}s.\n${_describeFailures(failuresSeen)}',
      timeout,
    ),
  ).whenComplete(subscription.cancel);
}

/// Failures are reported but never awaited on, so a timeout can still say what
/// went wrong instead of only that nothing arrived.
String _describeFailures(List<Failure> failures) {
  if (failures.isEmpty) {
    return 'No failure state was emitted either — the action likely never '
        'reached the controller.';
  }
  return 'Failures emitted while waiting (this controller is a shared bus, so '
      'these may be unrelated background work):\n'
      '${failures.map((failure) => '  - $failure').join('\n')}';
}
