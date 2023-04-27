import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/password.dart';
import 'package:model/user/user_profile.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_datasource.dart';

class AuthenticationDataSourceImpl extends AuthenticationDataSource {

  AuthenticationDataSourceImpl();

  @override
  Future<UserProfile> authenticationUser(Uri baseUrl, UserName userName, Password password) {
    return Future.sync(() {
      return UserProfile(userName.value);
    });
  }
}