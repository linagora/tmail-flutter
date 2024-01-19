import 'package:model/oidc/openid_configuration.dart';
import 'package:model/oidc/token_oidc.dart';

abstract class SaasAuthenticationRepository {
  Future<TokenOIDC> signUp(Uri registrationSiteUrl, String clientId, String redirectQueryParameter);

  Future<TokenOIDC> signIn(Uri registrationSiteUrl, String clientId, String redirectQueryParameter);

  Future<OpenIdConfiguration> discoverOpenIdConfiguration(Uri registrationSiteUrl);
}