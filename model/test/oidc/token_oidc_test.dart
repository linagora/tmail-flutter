import 'package:flutter_test/flutter_test.dart';
import 'package:model/exceptions/token_oidc_exceptions.dart';
import 'package:model/oidc/token_oidc.dart';

void main() {
  group('TokenOIDC.fromUrl', () {
    test('returns TokenOIDC instance on successful parsing', () {
      const uriString = 'https://example.com/callback?access_token=valid_access&refresh_token=valid_refresh&id_token=valid_id&expires_in=3600';
      final token = TokenOIDC.fromUri(uriString);

      expect(token.token, 'valid_access');
      expect(token.refreshToken, 'valid_refresh');
      expect(token.tokenId.uuid, 'valid_id');
      expect(token.expiredTime?.isAfter(DateTime.now()), isTrue);
    });

    test('throws AccessTokenIsNullException if access_token is missing', () {
      const uriString = 'https://example.com/callback?refresh_token=valid_refresh&id_token=valid_id&expires_in=3600';

      expect(() => TokenOIDC.fromUri(uriString), throwsA(isA<AccessTokenIsNullException>()));
    });

    test('throws FormatException on invalid URL format', () {
      const uriString = '::Not valid URI::';

      expect(() => TokenOIDC.fromUri(uriString), throwsA(isA<FormatException>()));
    });
  });
}

