import 'package:model/account/authentication_type.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';

/// Mock implementation of AuthorizationInterceptors for testing purposes.
///
/// This class provides a test double that doesn't require the actual dependencies
/// of AuthorizationInterceptors (Dio, AuthenticationClient, etc.).
class MockAuthorizationInterceptors implements AuthorizationInterceptors {
  String? _currentToken;
  String? _basicAuthCredentials;
  AuthenticationType _authenticationType = AuthenticationType.none;

  void setCurrentToken(String? token) {
    _currentToken = token;
    _authenticationType = token != null && token.isNotEmpty
        ? AuthenticationType.oidc
        : AuthenticationType.none;
  }

  void setBasicAuthCredentials(String? credentials) {
    _basicAuthCredentials = credentials;
    _authenticationType = credentials != null && credentials.isNotEmpty
        ? AuthenticationType.basic
        : AuthenticationType.none;
  }

  void setAuthenticationType(AuthenticationType type) {
    _authenticationType = type;
  }

  @override
  String? get currentToken => _currentToken;

  @override
  String? get basicAuthCredentials => _basicAuthCredentials;

  @override
  AuthenticationType get authenticationType => _authenticationType;

  // Stub implementations for other interface methods that aren't used in strategy tests
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
