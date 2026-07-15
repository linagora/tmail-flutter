import 'package:core/presentation/state/failure.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

/// Routes an interactor failure through the centrally-registered
/// [UrgentExceptionHandler] (re-login, reconnect, connection errors), mirroring
/// `BaseController.onData`/`onError` for Riverpod flows that bypass
/// `consumeState`. Any such flow MUST call this on failure. See ADR-0103.
///
/// Unwraps either carrier like `BaseController`: a `Left(FeatureFailure)` (via
/// [FeatureFailure.exception]) or a bare [exception]. Returns `true` when the
/// exception was urgent and handled — the caller then skips its own error UI.
bool handleUrgentExceptionIfNeeded({Failure? failure, Object? exception}) {
  final handler = getBinding<UrgentExceptionHandler>();
  if (handler == null) return false;

  final resolvedException = _resolveUrgentException(
    failure: failure,
    exception: exception,
  );
  if (resolvedException == null ||
      !handler.validateUrgentException(resolvedException)) {
    return false;
  }

  handler.handleUrgentException(
    failure: failure,
    exception: resolvedException is Exception ? resolvedException : null,
  );
  return true;
}

/// `true` if [error] would be routed as urgent, without routing it. Same
/// resolution as [handleUrgentExceptionIfNeeded], so it never disagrees (ADR-0103).
bool isUrgentException(Object? error) {
  final handler = getBinding<UrgentExceptionHandler>();
  if (handler == null) return false;

  // Mirror the caller dispatch: a Failure carries the exception, else it is bare.
  final resolvedException = error is Failure
      ? _resolveUrgentException(failure: error)
      : _resolveUrgentException(exception: error);
  return resolvedException != null &&
      handler.validateUrgentException(resolvedException);
}

/// Unwraps the urgent exception from either carrier: a bare [exception] or a
/// `FeatureFailure` (via [FeatureFailure.exception]).
Object? _resolveUrgentException({Failure? failure, Object? exception}) =>
    exception ?? (failure is FeatureFailure ? failure.exception : null);
