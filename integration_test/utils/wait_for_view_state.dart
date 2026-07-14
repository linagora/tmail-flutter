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
Future<Success> waitForViewState(
  BaseController controller, {
  required bool Function(Success state) matcher,
  required String description,
  Duration timeout = TestTimeouts.long,
}) {
  final completer = Completer<Success>();
  late final StreamSubscription<Either<Failure, Success>> subscription;

  subscription = controller.viewState.stream.listen((state) {
    state.fold(
      (_) {},
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
      'within ${timeout.inSeconds}s',
      timeout,
    ),
  ).whenComplete(subscription.cancel);
}
