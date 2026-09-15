import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_mobile.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/oauth_authorization_error.dart';

/// [FlutterAppAuth.token] is a plain overridable instance method, so a
/// hand-written fake stands in for the plugin without any codegen.
class _ThrowingAppAuth extends FlutterAppAuth {
  _ThrowingAppAuth(this.error);

  final Object error;

  @override
  Future<TokenResponse> token(TokenRequest request) async => throw error;
}

class _RespondingAppAuth extends FlutterAppAuth {
  _RespondingAppAuth(this.response);

  final TokenResponse response;

  @override
  Future<TokenResponse> token(TokenRequest request) async => response;
}

final _currentToken = TokenOIDC(
  'the-old-access-token',
  TokenId('the-current-id-token'),
  'a-refresh-token',
);

void main() {
  group('AuthenticationClientMobile::refreshingTokensOIDC', () {
    // This is the wiring the mobile force-logout fix rests on: a plugin failure
    // must leave the client as a domain error. Deleting the catch that calls
    // handleException fails this test.
    test('surfaces a rejected refresh as the converted domain error', () async {
      final client = AuthenticationClientMobile(_ThrowingAppAuth(
        _appAuthException(
          error: 'invalid_grant',
          errorDescription: 'The refresh token has been revoked',
        ),
      ));

      await expectLater(
        _refresh(client),
        throwsA(
          isA<OAuthAuthorizationError>()
              .having((e) => e.error, 'error', 'invalid_grant')
              .having(
                (e) => e.message,
                'message',
                'The refresh token has been revoked',
              ),
        ),
      );
    });

    // A failure that never reached the token endpoint carries no OAuth code. It
    // has to stay a PlatformException so the session survives a flaky network.
    test('leaves a failure with no OAuth code as a PlatformException', () async {
      final pluginException = _appAuthException(message: 'Network error');
      final client = AuthenticationClientMobile(
        _ThrowingAppAuth(pluginException),
      );

      // Identity is the strongest form here: it proves the plugin exception is
      // neither converted nor re-wrapped on its way out.
      await expectLater(_refresh(client), throwsA(same(pluginException)));
    });

    // OIDC Core 12.2 lets a refresh response omit id_token. Without the fallback
    // the token fails isTokenValid(), which the classifier reads as a server
    // rejection — a legal response would log the user out.
    test('keeps the current id token when the response omits id_token', () async {
      final client = AuthenticationClientMobile(_RespondingAppAuth(
        _tokenResponse(accessToken: 'a-new-access-token'),
      ));

      final refreshed = await _refresh(client);

      expect(refreshed.token, 'a-new-access-token');
      expect(refreshed.tokenId, _currentToken.tokenId);
    });

    // Same contract for refresh_token, which the response may also omit.
    test('keeps the current refresh token when the response omits it', () async {
      final client = AuthenticationClientMobile(_RespondingAppAuth(
        _tokenResponse(accessToken: 'a-new-access-token', idToken: 'a-new-id-token'),
      ));

      final refreshed = await _refresh(client);

      expect(refreshed.tokenId, TokenId('a-new-id-token'));
      expect(refreshed.refreshToken, _currentToken.refreshToken);
    });
  });
}

TokenResponse _tokenResponse({
  required String accessToken,
  String? idToken,
  String? refreshToken,
}) {
  return TokenResponse(
    accessToken,
    refreshToken,
    DateTime.now().add(const Duration(hours: 1)),
    idToken,
    'Bearer',
    const <String>['openid'],
    const <String, dynamic>{},
  );
}

Future<TokenOIDC> _refresh(AuthenticationClientMobile client) => client
    .refreshingTokensOIDC(
      'client-id',
      'com.example.app://callback',
      'https://sso.example.com/.well-known/openid-configuration',
      const ['openid', 'profile'],
      _currentToken,
    );

/// Mirrors the shape the plugin builds from a token-endpoint failure: [error]
/// is the RFC 6749 code read out of the response body, null whenever the
/// failure never reached the OAuth server.
FlutterAppAuthPlatformException _appAuthException({
  String code = 'token_failed',
  String message = 'Failed to get token',
  String? error,
  String? errorDescription,
}) {
  return FlutterAppAuthPlatformException(
    code: code,
    message: message,
    platformErrorDetails: FlutterAppAuthPlatformErrorDetails(
      error: error,
      errorDescription: errorDescription,
    ),
  );
}
