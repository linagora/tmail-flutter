import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_response_extension.dart';

void main() {
  final currentToken = TokenOIDC(
    'current-access-token',
    TokenId('current-id-token'),
    'current-refresh-token',
    expiredTime: DateTime(2026, 1, 1),
  );

  TokenResponse response({
    String? accessToken = 'new-access-token',
    String? refreshToken,
    String? idToken,
  }) {
    return TokenResponse(
      accessToken,
      refreshToken,
      DateTime(2026, 6, 1),
      idToken,
      'Bearer',
      const <String>['openid'],
      const <String, dynamic>{},
    );
  }

  // A refresh response may omit id_token (OIDC Core 12.2). Every shape the two
  // plugins can produce for an absent field must fall back to the current one.
  group('toTokenOIDC::id_token fallback', () {
    test('keeps the current id token when the response omits it (null)', () {
      final result = response().toTokenOIDC(currentToken: currentToken);

      expect(result.tokenId, currentToken.tokenId);
    });

    test('keeps the current id token when the response carries an empty string', () {
      final result = response(idToken: '').toTokenOIDC(currentToken: currentToken);

      expect(result.tokenId, currentToken.tokenId);
    });

    // flutter_appauth_web builds id_token with jsonResponse["id_token"].toString()
    // and no null guard, so an absent id_token arrives as the 4-char string
    // "null" — not '' and not null:
    // https://github.com/linagora/flutter_appauth_web/blob/0952346bf781bd87b93b8c61619f81a264be52db/lib/flutter_appauth_web.dart#L179
    // Storing the sentinel would key the token cache by hash("null") and hand
    // "null" to the Drive exchange through currentOidcIdToken.
    test('keeps the current id token when the web plugin yields the "null" sentinel', () {
      final result = response(idToken: 'null').toTokenOIDC(currentToken: currentToken);

      expect(result.tokenId, currentToken.tokenId);
    });

    test('takes the new id token when the response carries one', () {
      final result =
          response(idToken: 'new-id-token').toTokenOIDC(currentToken: currentToken);

      expect(result.tokenId, TokenId('new-id-token'));
    });
  });

  // Locks the semantics master had as `refreshToken ?? maybeAvailableRefreshToken`.
  // Both call sites passed a non-nullable String, so only null ever fell back.
  group('toTokenOIDC::refresh_token keeps the pre-existing semantics', () {
    test('keeps the current refresh token when the response omits it (null)', () {
      final result = response().toTokenOIDC(currentToken: currentToken);

      expect(result.refreshToken, currentToken.refreshToken);
    });

    // Only null falls back. Neither plugin can produce '' here — web guards null
    // explicitly (flutter_appauth_web.dart:177) and mobile passes the native
    // map value through (method_channel_flutter_appauth.dart:66).
    test('keeps an empty refresh token as-is, the way master did', () {
      final result = response(refreshToken: '').toTokenOIDC(currentToken: currentToken);

      expect(result.refreshToken, '');
    });

    test('takes the new refresh token when the response carries one', () {
      final result = response(refreshToken: 'new-refresh-token')
          .toTokenOIDC(currentToken: currentToken);

      expect(result.refreshToken, 'new-refresh-token');
    });
  });

  group('toTokenOIDC::access token and expiry', () {
    test('takes the new access token and expiry from the response', () {
      final result = response().toTokenOIDC(currentToken: currentToken);

      expect(result.token, 'new-access-token');
      expect(result.expiredTime, DateTime(2026, 6, 1));
    });

    // Empty access token fails isTokenValid(), which the client turns into
    // AccessTokenInvalidException — the current token must NOT paper over it.
    test('does not fall back to the current access token when the response omits it', () {
      final result = response(accessToken: null).toTokenOIDC(currentToken: currentToken);

      expect(result.token, '');
    });
  });
}
