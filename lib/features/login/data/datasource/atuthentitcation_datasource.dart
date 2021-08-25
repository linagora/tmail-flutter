import 'package:model/model.dart';

abstract class AuthenticationDataSource {
  Future<UserProfile> authenticationUser(Uri baseUrl, UserName userName, Password password);
}