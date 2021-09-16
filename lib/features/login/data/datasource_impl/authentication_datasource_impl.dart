import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_datasource.dart';

class AuthenticationDataSourceImpl extends AuthenticationDataSource {

  AuthenticationDataSourceImpl();

  @override
  Future<UserProfile> authenticationUser(Uri baseUrl, UserName userName, Password password) {
    return Future.sync(() {
      return UserProfile(userName.userName);
    });
  }
}