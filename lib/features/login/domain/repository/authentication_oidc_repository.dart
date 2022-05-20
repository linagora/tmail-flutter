
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';

abstract class AuthenticationOIDCRepository {
  Future<bool> checkOIDCIsAvailable(OIDCRequest oidcRequest);

  Future<OIDCConfiguration> getOIDCConfiguration(Uri baseUri);
}