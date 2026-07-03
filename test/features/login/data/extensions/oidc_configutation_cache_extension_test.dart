import 'package:flutter_test/flutter_test.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:tmail_ui_user/features/login/data/extensions/oidc_configutation_cache_extension.dart';
import 'package:tmail_ui_user/features/login/data/model/oidc_configuration_cache.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';

void main() {
  const authority = 'https://sso.example.com';

  group('OidcConfigurationCache <-> OIDCConfiguration ssoConfirmed mapping', () {
    test('WHEN cache.ssoConfirmed is null (legacy entry) THEN it maps to false', () {
      final config = OidcConfigurationCache(authority, false).toOIDCConfiguration();

      expect(config.ssoConfirmed, isFalse);
    });

    test('WHEN cache.ssoConfirmed is true THEN it maps to true', () {
      final config = OidcConfigurationCache(authority, false, ssoConfirmed: true)
          .toOIDCConfiguration();

      expect(config.ssoConfirmed, isTrue);
    });

    test('WHEN a confirmed config is cached and read back THEN ssoConfirmed survives the round-trip', () {
      final restored = OIDCConfiguration(
        authority: authority,
        clientId: 'client-id',
        scopes: const ['openid'],
        ssoConfirmed: true,
      ).toOidcConfigurationCache().toOIDCConfiguration();

      expect(restored.ssoConfirmed, isTrue);
    });

    test('WHEN a guessed config is cached and read back THEN ssoConfirmed stays false', () {
      final restored = OIDCConfiguration(
        authority: authority,
        clientId: 'client-id',
        scopes: const ['openid'],
      ).toOidcConfigurationCache().toOIDCConfiguration();

      expect(restored.ssoConfirmed, isFalse);
    });
  });
}
