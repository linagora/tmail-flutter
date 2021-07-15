import 'package:model/model.dart';

abstract class AuthenticationDataSource {
  Future<User> authenticationUser(Uri baseUrl, UserName userName, Password password);
}