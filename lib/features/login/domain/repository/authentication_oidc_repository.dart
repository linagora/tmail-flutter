
import 'package:model/oidc/request/oidc_request.dart';

abstract class AuthenticationOIDCRepository {
  Future<bool> checkOIDCIsAvailable(OIDCRequest oidcRequest);
}