import 'package:core/presentation/state/failure.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../entity/workplace_access_mode.dart';
import '../exceptions/workplace_exceptions.dart';
import '../state/workplace_intent_state.dart';
import 'exchange_drive_token_interactor.dart';
import 'workplace_action.dart';
import '../../data/bridge/cozy_bridge.dart';

/// Triggers the host app's OIDC refresh; returns the refreshed id token.
typedef OidcRefreshTrigger = Future<String?> Function();

/// Runs one Workplace action over bridge or bearer token, resolved once so
/// every request the action sends shares it and costs at most one exchange.
class WorkplaceAccessModeRunner {
  WorkplaceAccessModeRunner({
    required ExchangeDriveTokenInteractor exchangeTokenInteractor,
    required String? Function() oidcTokenGetter,
    required OidcRefreshTrigger oidcRefreshTrigger,
  })  : _exchangeTokenInteractor = exchangeTokenInteractor,
        _oidcTokenGetter = oidcTokenGetter,
        _oidcRefreshTrigger = oidcRefreshTrigger;

  final ExchangeDriveTokenInteractor _exchangeTokenInteractor;
  final String? Function() _oidcTokenGetter;
  final OidcRefreshTrigger _oidcRefreshTrigger;

  Future<T> run<T>(Uri platformUrl, WorkplaceAction<T> action) async {
    if (_canUseBridge(action)) {
      // No bearer retry for non-idempotent actions — the bridge may have already dispatched.
      if (!action.fallsBackToBearer) return action(const BridgeAccessMode());
      try {
        return await action(const BridgeAccessMode());
      } catch (error) {
        logWarning(
          'WorkplaceAccessModeRunner::run: bridge failed, falling back to bearer token: $error',
          webConsoleEnabled: true,
        );
      }
    }
    final oidcToken = _oidcTokenGetter();
    if (oidcToken == null) throw StateError('OIDC token is unavailable');
    final accessToken = await _exchangeAccessToken(platformUrl, oidcToken);
    if (accessToken == null) throw StateError('Drive access token exchange failed');
    return action(BearerTokenAccessMode(accessToken));
  }

  bool _canUseBridge(WorkplaceAction<Object?> action) =>
      action.supportsBridge && CozyBridge.isSupported && CozyBridge.isAvailable;

  Future<String?> _exchangeAccessToken(
    Uri platformUrl,
    String oidcToken, {
    bool refreshAttempted = false,
  }) async {
    final result = await _requestAccessToken(platformUrl, oidcToken);
    return result.fold(
      (failure) => _triggerRefreshOIDCToken(
        platformUrl: platformUrl,
        failedToken: oidcToken,
        failure: failure,
        refreshAttempted: refreshAttempted,
      ),
      (accessToken) => accessToken,
    );
  }

  Future<Either<Object, String?>> _requestAccessToken(
    Uri platformUrl,
    String oidcToken,
  ) async {
    String? accessToken;
    Object? caughtFailure;
    await for (final either in _exchangeTokenInteractor.execute(
      platformUrl,
      oidcToken,
    )) {
      either.fold(
        // reported by DriveIntentMessageHandlerMixin._failWith, the single funnel.
        (failure) => caughtFailure =
            failure is FeatureFailure ? failure.exception : WorkplaceExchangeTokenException(),
        (success) {
          if (success is ExchangeWorkplaceTokenSuccess) {
            accessToken = success.accessToken;
          }
        },
      );
    }
    return caughtFailure == null ? Right(accessToken) : Left(caughtFailure!);
  }

  /// Retries once on a stale-token response: reuses a concurrently refreshed
  /// token if one exists, else triggers a refresh.
  Future<String?> _triggerRefreshOIDCToken({
    required Uri platformUrl,
    required String failedToken,
    required Object failure,
    required bool refreshAttempted,
  }) async {
    if (refreshAttempted || !_isStaleSubjectToken(failure)) {
      throw failure;
    }

    // Mirrors AuthorizationInterceptors.validateToRetryTheRequestWithNewToken.
    final currentToken = _oidcTokenGetter();
    if (currentToken != null && currentToken != failedToken) {
      return _exchangeAccessToken(platformUrl, currentToken, refreshAttempted: true);
    }

    final refreshedToken = await _oidcRefreshTrigger();
    // Trace level: rides into Sentry as a breadcrumb on _failWith.
    logTrace(
      'WorkplaceAccessModeRunner::_triggerRefreshOIDCToken',
      extras: {
        'refreshReturnedToken': refreshedToken != null,
        'refreshReturnedSameToken': refreshedToken == failedToken,
      },
      webConsoleEnabled: true,
    );
    // IdP may omit id_token on refresh; retrying then would just re-401.
    if (refreshedToken == null || refreshedToken == failedToken) throw failure;

    return _exchangeAccessToken(platformUrl, refreshedToken, refreshAttempted: true);
  }

  // RFC 8693 invalid_grant is 400; token_exchange has also answered 401.
  bool _isStaleSubjectToken(Object failure) {
    if (failure is! DioException) return false;
    final statusCode = failure.response?.statusCode;
    return statusCode == 400 || statusCode == 401;
  }
}
