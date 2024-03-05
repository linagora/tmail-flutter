
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/password.dart';

abstract class AuthenticationRepository {
  Future<UserName> authenticationUser(Uri baseUrl, UserName userName, Password password);
}