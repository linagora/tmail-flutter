
import 'package:model/model.dart';

abstract class AuthenticationOIDCDataSource {
  Future<bool> checkOIDCIsAvailable(OIDCRequest oidcRequest);

  Future<OIDCConfiguration> getOIDCConfiguration(Uri baseUri);
}