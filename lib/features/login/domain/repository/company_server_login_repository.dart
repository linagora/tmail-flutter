import 'package:tmail_ui_user/features/login/domain/model/company_server_login_info.dart';

abstract class CompanyServerLoginRepository {
  Future<void> saveCompanyServerLoginInfo(CompanyServerLoginInfo loginInfo);

  Future<CompanyServerLoginInfo> getCompanyServerLoginInfo();

  Future<void> removeCompanyServerLoginInfo();
}
