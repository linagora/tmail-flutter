import 'package:core/presentation/state/failure.dart';
import 'package:tmail_ui_user/features/login/domain/state/authenticate_oidc_on_browser_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authentication_info_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';

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
}

bool _matchesAuthenticationInfoRecovery(Failure failure) =>
    failure is GetAuthenticationInfoFailure;

bool _matchesAuthenticatedAccountRecovery(Failure failure) =>
    failure is GetAuthenticatedAccountFailure;

bool _matchesNonNetworkSSORedirect(Failure failure) =>
    failure.isConfirmedSSORedirectFailure &&
    failure.exceptionOrNull is! NetworkException;
