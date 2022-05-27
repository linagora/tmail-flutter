import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';

class AuthenticationOIDCRepositoryImpl extends AuthenticationOIDCRepository {
  final AuthenticationOIDCDataSource _oidcDataSource;

  AuthenticationOIDCRepositoryImpl(this._oidcDataSource);

  @override
  Future<OIDCResponse> checkOIDCIsAvailable(OIDCRequest oidcRequest) {
    return _oidcDataSource.checkOIDCIsAvailable(oidcRequest);
  }

  @override
  Future<OIDCConfiguration> getOIDCConfiguration(Uri baseUri, OIDCResponse oidcResponse) {
    return _oidcDataSource.getOIDCConfiguration(baseUri, oidcResponse);
  }

  @override
  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl, String discoveryUrl, List<String> scopes) {
    return _oidcDataSource.getTokenOIDC(clientId, redirectUrl, discoveryUrl, scopes);
  }
}