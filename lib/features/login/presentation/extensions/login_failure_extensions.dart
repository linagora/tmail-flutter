import 'package:core/presentation/state/failure.dart';
import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/state/authenticate_oidc_on_browser_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authentication_info_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';

typedef LoginFailurePredicate = bool Function(Failure failure);

/// Failures emitted while web login silently re-authenticates on app open
/// (recovery chain + confirmed-SSO redirect); silenced unless they have a known message.
final List<LoginFailurePredicate> _silentReAuthenticationPredicates = [
  _matchesAuthenticationInfoRecovery,
  _matchesAuthenticatedAccountRecovery,
  _matchesNonNetworkSSORedirect,
];

extension LoginFailureExtensions on Failure {
  Object? get exceptionOrNull =>
      this is FeatureFailure ? (this as FeatureFailure).exception : null;

  /// Redirect failure on a confirmed-SSO server. On app open it is the silent
  /// re-authentication redirecting to SSO, so it must not flash an error.
  bool get isConfirmedSSORedirectFailure {
    final failure = this;
    return (failure is GetTokenOIDCFailure && failure.ssoConfirmed) ||
        (failure is AuthenticateOidcOnBrowserFailure && failure.ssoConfirmed);
  }

  bool get isSilentReAuthenticationFailure =>
      _silentReAuthenticationPredicates.any((predicate) => predicate(this));

  bool shouldHideRetryDuringSilentReAuthentication({
    required ToastManager? toastManager,
    required AppLocalizations appLocalizations,
  }) {
    if (!isSilentReAuthenticationFailure) {
      return false;
    }

    final exception = exceptionOrNull;
    if (exception is AutoRedirectToAppAfterStoreAuthorizeDestinationUrlException) {
      return true;
    }

    return PlatformInfo.isWeb &&
        !_hasVisibleMessage(
          toastManager,
          appLocalizations,
          exception,
        );
  }
}

bool _hasVisibleMessage(
  ToastManager? toastManager,
  AppLocalizations appLocalizations,
  Object? exception,
) {
  final message = toastManager?.getMessageByException(
    appLocalizations,
    exception,
  );
  return message?.isNotEmpty == true;
}

bool _matchesAuthenticationInfoRecovery(Failure failure) =>
    failure is GetAuthenticationInfoFailure;

bool _matchesAuthenticatedAccountRecovery(Failure failure) =>
    failure is GetAuthenticatedAccountFailure;

bool _matchesNonNetworkSSORedirect(Failure failure) =>
    failure.isConfirmedSSORedirectFailure &&
    failure.exceptionOrNull is! NetworkException;
