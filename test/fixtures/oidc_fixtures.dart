
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';

class OIDCFixtures {
  static final tokenOidcExpiredTime = TokenOIDC(
    'dab123',
    TokenId('dab123'),
    'dab456',
    expiredTime: DateTime.now().subtract(const Duration(days: 1)));

  static final tokenOidcExpiredTimeAndRefreshTokenEmpty = TokenOIDC(
    'dab123',
    TokenId('dab123'),
    '',
    expiredTime: DateTime.now().subtract(const Duration(days: 1)));

  static final tokenOidcExpiredTimeAndTokenEmpty = TokenOIDC(
    '',
    TokenId('dab123'),
    'dab456',
    expiredTime: DateTime.now().subtract(const Duration(days: 1)));

  static final newTokenOidc = TokenOIDC(
    'test123',
    TokenId('test123'),
    'test456',
    expiredTime: DateTime.now().add(const Duration(days: 1)));

  /// Token that is NOT expired yet - for testing 401 before expiry scenario
  static final tokenOidcNotExpiredYet = TokenOIDC(
    'valid_token_123',
    TokenId('valid_token_123'),
    'valid_refresh_456',
    expiredTime: DateTime.now().add(const Duration(hours: 1)));

  static final oidcConfiguration = OIDCConfiguration(
    authority: 'https://example.com',
    clientId: 'client-id',
    scopes: ['scope1', 'scope2', 'scope3']);
}