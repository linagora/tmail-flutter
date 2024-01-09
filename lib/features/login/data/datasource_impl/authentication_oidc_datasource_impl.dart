import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_discovery_response.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class AuthenticationOIDCDataSourceImpl extends AuthenticationOIDCDataSource {

  final OIDCHttpClient _oidcHttpClient;
  final AuthenticationClientBase _authenticationClient;
  final ExceptionThrower _exceptionThrower;

  AuthenticationOIDCDataSourceImpl(
    this._oidcHttpClient,
    this._authenticationClient,
    this._exceptionThrower
  );

  @override
  Future<OIDCResponse> checkOIDCIsAvailable(OIDCRequest oidcRequest) {
    return Future.sync(() async {
      return await _oidcHttpClient.checkOIDCIsAvailable(oidcRequest);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<OIDCDiscoveryResponse> discoverOIDC(OIDCConfiguration oidcConfiguration) {
    return Future.sync(() async {
      return await _oidcHttpClient.discoverOIDC(oidcConfiguration);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<TokenOIDC> getTokenOIDC(OIDCConfiguration oidcConfiguration) {
    return Future.sync(() async {
      return await _authenticationClient.getTokenOIDC(oidcConfiguration);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<TokenOIDC> refreshingTokensOIDC(OIDCConfiguration oidcConfiguration, String refreshToken) {
    return Future.sync(() async {
      return await _authenticationClient.refreshingTokensOIDC(oidcConfiguration, refreshToken);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> logout(TokenId tokenId, OIDCConfiguration config, OIDCDiscoveryResponse oidcDiscoveryResponse) {
    return Future.sync(() async {
       return await _authenticationClient.logoutOidc(tokenId, config, oidcDiscoveryResponse);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> authenticateOidcOnBrowser(OIDCConfiguration oidcConfiguration) {
    return Future.sync(() async {
      return await _authenticationClient.authenticateOidcOnBrowser(oidcConfiguration);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<String> getAuthResponseUrlBrowser() {
    return Future.sync(() async {
      return await _authenticationClient.getAuthResponseUrlBrowser();
    }).catchError(_exceptionThrower.throwException);
  }
}