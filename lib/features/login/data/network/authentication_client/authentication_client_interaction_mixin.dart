import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_appauth_platform_interface/flutter_appauth_platform_interface.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/response/oidc_discovery_response.dart';
import 'package:model/oidc/token_id.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/oauth_authorization_error.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';

mixin AuthenticationClientInteractionMixin {
  /// Validates the OIDC discovery response and throws specific exceptions
  /// if required endpoints are missing.
  void validateOidcDiscoveryResponse(OIDCDiscoveryResponse discoveryResponse) {
    log('AuthenticationClientInteractionMixin::validateOidcDiscoveryResponse: '
        'authorizationEndpoint=${discoveryResponse.authorizationEndpoint}, '
        'tokenEndpoint=${discoveryResponse.tokenEndpoint}, '
        'endSessionEndpoint=${discoveryResponse.endSessionEndpoint}');

    if (discoveryResponse.authorizationEndpoint == null) {
      throw MissingAuthorizationEndpointException();
    }
    if (discoveryResponse.tokenEndpoint == null) {
      throw MissingTokenEndpointException();
    }
  }

  /// Checks if end_session_endpoint is available for logout.
  /// Returns true if available, false otherwise.
  bool hasEndSessionEndpoint(OIDCDiscoveryResponse discoveryResponse) {
    final hasEndpoint = discoveryResponse.endSessionEndpoint != null;
    if (!hasEndpoint) {
      log('AuthenticationClientInteractionMixin::hasEndSessionEndpoint: '
          'end_session_endpoint is not available in OIDC discovery response. '
          'This is optional per OIDC spec - will perform local-only logout.');
    }
    return hasEndpoint;
  }

  EndSessionRequest? getEndSessionRequest(
    TokenId tokenId,
    OIDCConfiguration config,
    OIDCDiscoveryResponse discoveryResponse,
  ) {
    // Check if end_session_endpoint is available (optional per OIDC spec)
    if (!hasEndSessionEndpoint(discoveryResponse)) {
      log('AuthenticationClientInteractionMixin::getEndSessionRequest: '
          'Returning null - end_session_endpoint not configured on server.');
      return null;
    }

    final authorizationEndpoint = discoveryResponse.authorizationEndpoint;
    final tokenEndpoint = discoveryResponse.tokenEndpoint;
    AuthorizationServiceConfiguration? serviceConfiguration;

    if (authorizationEndpoint != null && tokenEndpoint != null) {
      serviceConfiguration = AuthorizationServiceConfiguration(
        authorizationEndpoint: authorizationEndpoint,
        tokenEndpoint: tokenEndpoint,
        endSessionEndpoint: discoveryResponse.endSessionEndpoint,
      );
    }

    return EndSessionRequest(
      idTokenHint: tokenId.uuid,
      postLogoutRedirectUrl: config.logoutRedirectUrl,
      discoveryUrl: config.discoveryUrl,
      serviceConfiguration: serviceConfiguration,
      externalUserAgent: getExternalUserAgent(),
    );
  }

  ExternalUserAgent getExternalUserAgent() => PlatformInfo.isIOS
      ? ExternalUserAgent.ephemeralAsWebAuthenticationSession
      : ExternalUserAgent.asWebAuthenticationSession;

  TokenRequest getRefreshTokenRequest(
    String clientId,
    String redirectUrl,
    String discoveryUrl,
    String refreshToken,
    List<String> scopes,
  ) {
    return TokenRequest(
      clientId,
      redirectUrl,
      discoveryUrl: discoveryUrl,
      refreshToken: refreshToken,
      grantType: GrantType.refreshToken,
      scopes: scopes,
    );
  }

  AuthorizationTokenRequest getAuthorizationTokenRequest(
    String clientId,
    String redirectUrl,
    String discoveryUrl,
    List<String> scopes, {
    String? loginHint,
  }) {
    return AuthorizationTokenRequest(
      clientId,
      redirectUrl,
      discoveryUrl: discoveryUrl,
      scopes: scopes,
      externalUserAgent: getExternalUserAgent(),
      loginHint: loginHint,
    );
  }

  dynamic handleException(dynamic exception) {
    if (exception is FlutterAppAuthPlatformException) {
      logWarning('$runtimeType::handleException: ErrorDetails = ${exception.platformErrorDetails.toString()}');
      final errorCode = exception.platformErrorDetails.error;
      if (errorCode != null) {
        final oauthErrorCode = OAuthAuthorizationError.fromErrorCode(
          errorCode,
          errorDescription: exception.platformErrorDetails.errorDescription,
        );
        return oauthErrorCode;
      }
    }

    return exception;
  }
}
