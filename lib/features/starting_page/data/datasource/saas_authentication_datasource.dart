
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';

abstract class SaasAuthenticationDataSource {
  Future<TokenOIDC> signInTwakeWorkplace(OIDCConfiguration oidcConfiguration);

  Future<TokenOIDC> signUpTwakeWorkplace(OIDCConfiguration oidcConfiguration);
}