import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/login_exception.dart';
import 'package:tmail_ui_user/features/login/domain/model/company_server_login_info.dart';

class CompanyServerLoginCacheManager {
  static const String _companyServerLoginInfoKey = 'COMPANY_SERVER_LOGIN_INFO';

  const CompanyServerLoginCacheManager(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  CompanyServerLoginInfo getCompanyServerLoginInfo() {
    final userEmail = _sharedPreferences.getString(_companyServerLoginInfoKey);
    if (userEmail?.trim().isNotEmpty == true) {
      return CompanyServerLoginInfo(email: userEmail!);
    } else {
      throw NotFoundCompanyServerLoginInfoException();
    }
  }

  Future<void> saveCompanyServerLoginInfo(
    CompanyServerLoginInfo companyServerLoginInfo,
  ) async {
    await _sharedPreferences.setString(
        _companyServerLoginInfoKey, companyServerLoginInfo.email);
  }

  Future<void> removeCompanyServerLoginInfo() async {
    await _sharedPreferences.remove(_companyServerLoginInfoKey);
  }
}
