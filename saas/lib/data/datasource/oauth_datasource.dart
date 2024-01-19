import 'package:model/oidc/openid_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:saas/data/model/token_request.dart';

abstract class OAuthDataSource {
  Future<TokenOIDC> getOIDCToken(
    OpenIdConfiguration openIdConfiguration,
    TokenRequest tokenRequest,
  );

  Future<OpenIdConfiguration> discoverOpenIdConfiguration(String discoveryUrl);
}