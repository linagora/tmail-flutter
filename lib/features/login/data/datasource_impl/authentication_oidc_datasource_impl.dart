import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';

class AuthenticationOIDCDataSourceImpl extends AuthenticationOIDCDataSource {

  final OIDCHttpClient _oidcHttpClient;
  final TokenOidcCacheManager _tokenOidcCacheManager;

  AuthenticationOIDCDataSourceImpl(this._oidcHttpClient, this._tokenOidcCacheManager);

  @override
  Future<OIDCResponse> checkOIDCIsAvailable(OIDCRequest oidcRequest) {
    return Future.sync(() async {
      final oidcResponse = await _oidcHttpClient.checkOIDCIsAvailable(oidcRequest);
      return oidcResponse!;
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<OIDCConfiguration> getOIDCConfiguration(Uri baseUri, OIDCResponse oidcResponse) {
    return Future.sync(() async {
      return await _oidcHttpClient.getOIDCConfiguration(baseUri, oidcResponse);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl, String discoveryUrl, List<String> scopes) {
    return Future.sync(() async {
      return await _oidcHttpClient.getTokenOIDC(clientId, redirectUrl, discoveryUrl, scopes);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<TokenOIDC> getStoredTokenOIDC(String tokenIdHash) async {
    return _tokenOidcCacheManager.getTokenOidc(tokenIdHash);
  }

  @override
  Future<void> persistTokenOIDC(TokenOIDC tokenOidc) async {
    return _tokenOidcCacheManager.persistOneTokenOidc(tokenOidc);
  }
}