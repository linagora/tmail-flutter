import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/datasource/atuthentitcation_datasource.dart';
import 'package:tmail_ui_user/features/login/data/model/request/account_request.dart';
import 'package:tmail_ui_user/features/login/data/model/response/user_profile_response.dart';
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