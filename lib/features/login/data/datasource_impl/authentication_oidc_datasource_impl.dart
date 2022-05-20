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
}