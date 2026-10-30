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

/// Applies an already-logged failure (UI / state only). Urgent routing may or
/// may not have run depending on [ShouldRouteUrgentException].
typedef InteractorFailureHandler = void Function(
  Object error,
  StackTrace stackTrace,
);

/// Whether the resolved exception should be offered to ADR-0103 urgent routing.
///
/// [InteractorConsumer] unwraps a `Left` [FeatureFailure] to
/// [FeatureFailure.exception] (or keeps a bare thrown object) before calling
/// this, matching [handleUrgentExceptionIfNeeded]. Returning `false` skips
/// urgent routing (soft-fail); `true` keeps the default route. See ADR-0103
/// optional-discovery exception.
typedef ShouldRouteUrgentException = bool Function(Object error);

/// Bundles [InteractorConsumer.consumeInteractor] inputs into one request
/// object to keep the seam signature small and stable as options grow.
class InteractorConsumeRequest {
  final InteractorCall run;
  final StaleGuard isStale;
  final InteractorSuccessHandler onSuccess;
  final InteractorFailureHandler onFailure;
  final ShouldRouteUrgentException? shouldRouteUrgentException;

  const InteractorConsumeRequest({
    required this.run,
    required this.isStale,
    required this.onSuccess,
    required this.onFailure,
    this.shouldRouteUrgentException,
  });
}

/// Riverpod analogue of `BaseController.consumeState`: the one interactor-consume
/// seam. Logs and routes urgent exceptions (ADR-0103) so consumers can't forget.
mixin InteractorConsumer {
  /// Awaits [InteractorConsumeRequest.run], drops the result when stale,
  /// dispatches the outcome. Failures are logged + optionally routed before
  /// [InteractorConsumeRequest.onFailure], which only touches UI/state.
  ///
  /// [InteractorConsumeRequest.shouldRouteUrgentException] defaults to routing
  /// every failure (ADR-0103). Pass a predicate to soft-fail selected classes
  /// (e.g. connectivity on an optional discovery call) without suppressing
  /// auth re-login.
  Future<bool> consumeInteractor(InteractorConsumeRequest request) async {
    // Scope the try to run() only: a bug thrown by onSuccess/onFailure must
    // surface, not be misclassified (and maybe urgent-routed) as a failure.
    final Either<Failure, Success> result;
    try {
      result = await request.run();
    } catch (error, stackTrace) {
      if (request.isStale()) return false;
      _fail(error, stackTrace, request);
      return false;
    }
    if (request.isStale()) return false;
    var succeeded = true;
    result.fold(
      (failure) {
        succeeded = false;
        _fail(failure, StackTrace.current, request);
      },
      request.onSuccess,
    );
    return succeeded;
  }

  /// Logs the failure (no filter/email content), optionally routes urgent ones
  /// through the shared primitive, then delegates to [onFailure].
  void _fail(
    Object error,
    StackTrace stackTrace,
    InteractorConsumeRequest request,
  ) {
    logError(
      'InteractorConsumer::consumeInteractor: interactor failed',
      exception: error,
      stackTrace: stackTrace,
    );
    final shouldRoute = request.shouldRouteUrgentException;
    // Normalize before the predicate so type-only filters (is! ConnectionError)
    // soft-fail Left(FeatureFailure(ConnectionError)) the same as a bare throw.
    final routeError =
        error is FeatureFailure ? (error.exception ?? error) : error;
    if (shouldRoute == null || shouldRoute(routeError)) {
      error is Failure
          ? handleUrgentExceptionIfNeeded(failure: error)
          : handleUrgentExceptionIfNeeded(exception: error);
    }
    request.onFailure(error, stackTrace);
  }
}
