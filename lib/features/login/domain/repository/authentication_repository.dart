
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/password.dart';
import 'package:model/user/user_profile.dart';

abstract class AuthenticationRepository {
  Future<UserProfile> authenticationUser(Uri baseUrl, UserName userName, Password password);
}