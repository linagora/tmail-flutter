import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';

class AuthenticationOIDCDataSourceImpl extends AuthenticationOIDCDataSource {

  final OIDCHttpClient _oidcHttpClient;

  AuthenticationOIDCDataSourceImpl(this._oidcHttpClient);

  @override
  Future<bool> checkOIDCIsAvailable(OIDCRequest oidcRequest) {
    return Future.sync(() async {
      final oidcResponse = await _oidcHttpClient.checkOIDCIsAvailable(oidcRequest);
      return oidcResponse != null;
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<OIDCConfiguration> getOIDCConfiguration(Uri baseUri) {
    return Future.sync(() async {
      return await _oidcHttpClient.getOIDCConfiguration(baseUri);
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
}