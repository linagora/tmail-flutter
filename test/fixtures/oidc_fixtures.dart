
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';

class OIDCFixtures {
  static final tokenOidcExpiredTime = TokenOIDC(
    token: 'dab123',
    tokenId: TokenId('dab123'),
    refreshToken: 'dab456',
    authority: '',
    expiredTime: DateTime.now().subtract(const Duration(days: 1)));

  static final tokenOidcExpiredTimeAndRefreshTokenEmpty = TokenOIDC(
    token: 'dab123',
    tokenId: TokenId('dab123'),
    refreshToken: '',
    authority: '',
    expiredTime: DateTime.now().subtract(const Duration(days: 1)));

  static final tokenOidcExpiredTimeAndTokenEmpty = TokenOIDC(
    token: '',
    tokenId: TokenId('dab123'),
    refreshToken: 'dab456',
    authority: '',
    expiredTime: DateTime.now().subtract(const Duration(days: 1)));

  static final newTokenOidc = TokenOIDC(
    token: 'test123',
    tokenId: TokenId('test123'),
    refreshToken: 'test456',
    authority: '',
    expiredTime: DateTime.now().add(const Duration(days: 1)));

  static final oidcConfiguration = OIDCConfiguration(
    authority: 'https://example.com',
    clientId: 'client-id',
    scopes: ['scope1', 'scope2', 'scope3']);
}