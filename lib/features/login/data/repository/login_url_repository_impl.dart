import 'package:tmail_ui_user/features/login/data/datasource/login_url_datasource.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_url_repository.dart';

class LoginUrlRepositoryImpl implements LoginUrlRepository {
  final LoginUrlDataSource loginInfoDataSource;

  LoginUrlRepositoryImpl(this.loginInfoDataSource);
  
  @override
  Future<void> saveRecentLoginUrl(RecentLoginUrl recentLogin) {
    return loginInfoDataSource.saveLoginUrl(recentLogin);
  }
}