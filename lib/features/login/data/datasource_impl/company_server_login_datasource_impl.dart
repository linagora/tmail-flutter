import 'package:tmail_ui_user/features/login/data/datasource/company_server_login_datasource.dart';
import 'package:tmail_ui_user/features/login/data/local/company_server_login_cache_manager.dart';
import 'package:tmail_ui_user/features/login/domain/model/company_server_login_info.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class CompanyServerLoginDatasourceImpl implements CompanyServerLoginDataSource {
  final CompanyServerLoginCacheManager _loginCacheManager;
  final ExceptionThrower _exceptionThrower;

  CompanyServerLoginDatasourceImpl(
    this._loginCacheManager,
    this._exceptionThrower,
  );

  @override
  Future<CompanyServerLoginInfo> getCompanyServerLoginInfo() {
    return Future.sync(() {
      return _loginCacheManager.getCompanyServerLoginInfo();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeCompanyServerLoginInfo() {
    return Future.sync(() async {
      return await _loginCacheManager.removeCompanyServerLoginInfo();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> saveCompanyServerLoginInfo(CompanyServerLoginInfo loginInfo) {
    return Future.sync(() async {
      return await _loginCacheManager.saveCompanyServerLoginInfo(loginInfo);
    }).catchError(_exceptionThrower.throwException);
  }
}
