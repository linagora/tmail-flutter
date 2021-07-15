import 'package:model/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/login/data/utils/login_constant.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class CredentialRepositoryImpl extends CredentialRepository {

  final SharedPreferences sharedPreferences;

  CredentialRepositoryImpl(this.sharedPreferences);

  @override
  Future<Uri> getBaseUrl() async {
    return Uri.parse(sharedPreferences.getString(LoginConstant.keyBaseUrl) ?? '');
  }

  @override
  Future saveBaseUrl(Uri baseUrl) async {
    await sharedPreferences.setString(LoginConstant.keyBaseUrl, baseUrl.origin);
  }

  @override
  Future removeBaseUrl() async {
    await sharedPreferences.remove(LoginConstant.keyBaseUrl);
  }

  @override
  Future<Password> getPassword() async {
    return Password(sharedPreferences.getString(LoginConstant.keyPassword) ?? '');
  }

  @override
  Future removePassword() async {
    await sharedPreferences.remove(LoginConstant.keyPassword);
  }

  @override
  Future savePassword(Password password) async {
    await sharedPreferences.setString(LoginConstant.keyPassword, password.value);
  }

  @override
  Future<UserName> getUserName() async {
    return UserName(sharedPreferences.getString(LoginConstant.keyUserName) ?? '');
  }

  @override
  Future removeUserName() async {
    await sharedPreferences.remove(LoginConstant.keyUserName);
  }

  @override
  Future saveUserName(UserName userName) async {
    await sharedPreferences.setString(LoginConstant.keyUserName, userName.userName);
  }
}