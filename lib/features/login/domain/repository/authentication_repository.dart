import 'package:model/model.dart';

abstract class AuthenticationRepository {
  Future<User> authenticationUser(Uri baseUrl, UserName userName, Password password);
}