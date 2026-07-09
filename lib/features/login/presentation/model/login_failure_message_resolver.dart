import 'package:core/presentation/state/failure.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/login_exception.dart';
import 'package:tmail_ui_user/features/login/domain/state/dns_lookup_to_get_jmap_url_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/presentation/extensions/login_failure_extensions.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';

typedef LoginFailureMessageRule = String? Function(
  LoginFailureMessageContext context,
);

final List<LoginFailureMessageRule> _failureMessageRules = [
  _noNetworkMessage,
  _oidcConfigurationMessage,
  _dnsLookupMessage,
  _noSuitableBrowserMessage,
  _silentReAuthenticationMessage,
  _knownExceptionMessage,
];

class LoginFailureMessageResolver {
  const LoginFailureMessageResolver(this.toastManager);

  final ToastManager? toastManager;

  String resolve(
    AppLocalizations appLocalizations,
    Failure failure,
  ) {
    final context = LoginFailureMessageContext(
      appLocalizations: appLocalizations,
      failure: failure,
      knownExceptionMessage: _getKnownExceptionMessage(
        appLocalizations,
        failure,
      ),
    );
    final matchingMessages = _failureMessageRules
        .map((rule) => rule(context))
        .where((message) => message != null);

    return matchingMessages.isNotEmpty
        ? matchingMessages.first!
        : _defaultMessage(context);
  }

  String? _getKnownExceptionMessage(
    AppLocalizations appLocalizations,
    Failure failure,
  ) {
    return failure is FeatureFailure
        ? toastManager?.getMessageByException(
            appLocalizations,
            failure.exception,
          )
        : null;
  }

  String _defaultMessage(LoginFailureMessageContext context) {
    final failure = context.failure;

    return failure is FeatureFailure
        ? toastManager?.getMessageByException(
            context.appLocalizations,
            failure.exception,
            useDefaultMessage: true,
          ) ?? context.appLocalizations.unknownError
        : context.appLocalizations.unknownError;
  }
}

class LoginFailureMessageContext {
  const LoginFailureMessageContext({
    required this.appLocalizations,
    required this.failure,
    required this.knownExceptionMessage,
  });

  final AppLocalizations appLocalizations;
  final Failure failure;
  final String? knownExceptionMessage;
}

String? _noNetworkMessage(LoginFailureMessageContext context) {
  return context.failure.exceptionOrNull is NoNetworkError
      ? context.appLocalizations.youAreOffline
      : null;
}

String? _oidcConfigurationMessage(LoginFailureMessageContext context) {
  return context.failure is GetOIDCConfigurationFailure
      ? context.appLocalizations.canNotVerifySSOConfiguration
      : null;
}

String? _dnsLookupMessage(LoginFailureMessageContext context) {
  return context.failure is DNSLookupToGetJmapUrlFailure
      ? context.appLocalizations.dnsLookupLoginMessage
      : null;
}

String? _noSuitableBrowserMessage(LoginFailureMessageContext context) {
  return context.failure is GetTokenOIDCFailure &&
          context.failure.exceptionOrNull is NoSuitableBrowserForOIDCException
      ? context.appLocalizations.noSuitableBrowserForOIDC
      : null;
}

/// Silent re-authentication failures on app open render empty unless they carry
/// a known message; the user is being redirected to SSO, so nothing must flash.
String? _silentReAuthenticationMessage(LoginFailureMessageContext context) {
  return context.failure.isSilentReAuthenticationFailure &&
          context.knownExceptionMessage == null
      ? ''
      : null;
}

String? _knownExceptionMessage(LoginFailureMessageContext context) =>
    context.knownExceptionMessage;
