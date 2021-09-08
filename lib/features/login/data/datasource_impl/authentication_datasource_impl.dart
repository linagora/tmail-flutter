import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_datasource.dart';
import 'package:tmail_ui_user/features/login/data/network/login_api.dart';

class AuthenticationDataSourceImpl extends AuthenticationDataSource {

  final LoginAPI loginAPI;

  AuthenticationDataSourceImpl(this.loginAPI);

  @override
  Future<UserProfile> authenticationUser(Uri baseUrl, UserName userName, Password password) {
    return Future.sync(() async {
      final userProfileResponse = await loginAPI.authenticationUser(baseUrl, AccountRequest(userName, password));
      return userProfileResponse.toUserProfile();
    }).catchError((error) {
      throw error;
    });
  }
}