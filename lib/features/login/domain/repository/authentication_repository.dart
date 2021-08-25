import 'package:model/model.dart';

abstract class AuthenticationRepository {
  Future<UserProfile> authenticationUser(Uri baseUrl, UserName userName, Password password);
}