import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_discovery_response.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:model/oidc/token_id.dart';
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
  Future<OIDCDiscoveryResponse> discoverOIDC(OIDCConfiguration oidcConfiguration) {
    return _oidcDataSource.discoverOIDC(oidcConfiguration);
  }

  @override
  Future<TokenOIDC> getTokenOIDC(OIDCConfiguration oidcConfiguration) {
    return _oidcDataSource.getTokenOIDC(oidcConfiguration);
  }

  @override
  Future<TokenOIDC> refreshingTokensOIDC(OIDCConfiguration oidcConfiguration, String refreshToken) {
    return _oidcDataSource.refreshingTokensOIDC(oidcConfiguration, refreshToken);
  }

  @override
  Future<bool> logout(TokenId tokenId, OIDCConfiguration config, OIDCDiscoveryResponse oidcDiscoveryResponse) {
    return _oidcDataSource.logout(tokenId, config, oidcDiscoveryResponse);
  }

  @override
  Future<void> authenticateOidcOnBrowser(OIDCConfiguration oidcConfiguration) {
    return _oidcDataSource.authenticateOidcOnBrowser(oidcConfiguration);
  }

  @override
  Future<String> getAuthResponseUrlBrowser() {
    return _oidcDataSource.getAuthResponseUrlBrowser();
  }
}