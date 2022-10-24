import 'package:tmail_ui_user/features/login/data/datasource/login_username_datasource.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_username_repository.dart';

class LoginUsernameRepositoryImpl implements LoginUsernameRepository {
  final LoginUsernameDataSource loginUsernameDatasource;

  LoginUsernameRepositoryImpl(this.loginUsernameDatasource);
  
  @override
  Future<List<RecentLoginUsername>> getAllRecentLoginUsernameLatest({int? limit, String? pattern}) {
    return loginUsernameDatasource.getAllRecentLoginUsernamesLatest(limit: limit, pattern: pattern);
  }

  @override
  Future<void> saveLoginUsername(RecentLoginUsername recentLoginUsername) {
    return loginUsernameDatasource.saveLoginUsername(recentLoginUsername);
  }
}