import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/starting_page/data/datasource/saas_authentication_datasource.dart';
import 'package:tmail_ui_user/features/starting_page/domain/repository/saas_authentication_repository.dart';

class SaasAuthenticationRepositoryImpl extends SaasAuthenticationRepository {

  final SaasAuthenticationDataSource _saasAuthenticationDataSource;

  SaasAuthenticationRepositoryImpl(this._saasAuthenticationDataSource);

  @override
  Future<TokenOIDC> signInTwakeWorkplace(OIDCConfiguration oidcConfiguration) {
    return _saasAuthenticationDataSource.signInTwakeWorkplace(oidcConfiguration);
  }

  @override
  Future<TokenOIDC> signUpTwakeWorkplace(OIDCConfiguration oidcConfiguration) {
    return _saasAuthenticationDataSource.signUpTwakeWorkplace(oidcConfiguration);
  }
}