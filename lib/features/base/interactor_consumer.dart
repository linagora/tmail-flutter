import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/base/handle_urgent_exception.dart';

/// Invokes an interactor for one execution and yields its terminal result.
typedef InteractorCall = Future<Either<Failure, Success>> Function();

/// Returns true once the awaited result must be dropped (disposed / superseded).
typedef StaleGuard = bool Function();

/// Applies a terminal success.
typedef InteractorSuccessHandler = void Function(Success success);

/// Applies an already-logged, already-routed failure (UI / state only).
typedef InteractorFailureHandler = void Function(
  Object error,
  StackTrace stackTrace,
);

/// Riverpod analogue of `BaseController.consumeState`: the one interactor-consume
/// seam. Logs and routes urgent exceptions (ADR-0103) so consumers can't forget.
mixin InteractorConsumer {
  /// Awaits [run], drops the result when [isStale], dispatches the outcome.
  /// Failures are logged + routed before [onFailure], which only touches UI/state.
  Future<bool> consumeInteractor(
    InteractorCall run, {
    required StaleGuard isStale,
    required InteractorSuccessHandler onSuccess,
    required InteractorFailureHandler onFailure,
  }) async {
    // Scope the try to run() only: a bug thrown by onSuccess/onFailure must
    // surface, not be misclassified (and maybe urgent-routed) as a failure.
    final Either<Failure, Success> result;
    try {
      result = await run();
    } catch (error, stackTrace) {
      if (isStale()) return false;
      _fail(error, stackTrace, onFailure);
      return false;
    }
    if (isStale()) return false;
    var succeeded = true;
    result.fold(
      (failure) {
        succeeded = false;
        _fail(failure, StackTrace.current, onFailure);
      },
      onSuccess,
    );
    return succeeded;
  }

  /// Logs the failure (no filter/email content), routes urgent ones through the
  /// shared primitive, then delegates to [onFailure].
  void _fail(
    Object error,
    StackTrace stackTrace,
    InteractorFailureHandler onFailure,
  ) {
    logError(
      'InteractorConsumer::consumeInteractor: interactor failed',
      exception: error,
      stackTrace: stackTrace,
    );
    error is Failure
        ? handleUrgentExceptionIfNeeded(failure: error)
        : handleUrgentExceptionIfNeeded(exception: error);
    onFailure(error, stackTrace);
  }
}
