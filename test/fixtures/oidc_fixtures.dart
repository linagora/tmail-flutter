
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';

class OIDCFixtures {
  static final tokenOidcExpired = TokenOIDC(
    'dab123',
    TokenId('dab123'),
    'dab456',
    expiredTime: DateTime.tryParse('2024-01-22 10:00:00.000'));

  static final tokenOidcWithRefreshTokenEmpty = TokenOIDC(
    'dab123',
    TokenId('dab123'),
    '',
    expiredTime: DateTime.tryParse('2024-01-22 10:00:00.000'));

  static final tokenOidc = TokenOIDC(
    'test123',
    TokenId('test123'),
    'test456',
    expiredTime: DateTime.tryParse('2024-01-24 10:00:00.000'));

  static final oidcConfiguration = OIDCConfiguration(
    authority: 'https://example.com',
    clientId: 'client-id',
    scopes: ['email', 'openid', 'profile']);
}