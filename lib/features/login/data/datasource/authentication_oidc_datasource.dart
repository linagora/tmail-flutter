
import 'package:model/model.dart';

abstract class AuthenticationOIDCDataSource {
  Future<bool> checkOIDCIsAvailable(OIDCRequest oidcRequest);

  Future<OIDCConfiguration> getOIDCConfiguration(Uri baseUri);

  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl, String discoveryUrl, List<String> scopes);
}