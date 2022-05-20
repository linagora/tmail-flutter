
import 'package:model/model.dart';

abstract class AuthenticationOIDCDataSource {
  Future<bool> checkOIDCIsAvailable(OIDCRequest oidcRequest);
}