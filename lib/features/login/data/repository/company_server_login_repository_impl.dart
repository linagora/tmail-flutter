import 'package:tmail_ui_user/features/login/data/datasource/company_server_login_datasource.dart';
import 'package:tmail_ui_user/features/login/domain/model/company_server_login_info.dart';
import 'package:tmail_ui_user/features/login/domain/repository/company_server_login_repository.dart';

class CompanyServerLoginRepositoryImpl implements CompanyServerLoginRepository {
  final CompanyServerLoginDataSource _serverLoginDataSource;

  CompanyServerLoginRepositoryImpl(this._serverLoginDataSource);

  @override
  Future<CompanyServerLoginInfo> getCompanyServerLoginInfo() {
    return _serverLoginDataSource.getCompanyServerLoginInfo();
  }

  @override
  Future<void> removeCompanyServerLoginInfo() {
    return _serverLoginDataSource.removeCompanyServerLoginInfo();
  }

  @override
  Future<void> saveCompanyServerLoginInfo(CompanyServerLoginInfo loginInfo) {
    return _serverLoginDataSource.saveCompanyServerLoginInfo(loginInfo);
  }
}
