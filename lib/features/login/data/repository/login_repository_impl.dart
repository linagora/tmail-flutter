import 'package:core/core.dart';
import 'package:tmail_ui_user/features/login/data/datasource/login_datasource.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final Map<DataSourceType, LoginDataSource> _loginDataSource;

  LoginRepositoryImpl(this._loginDataSource);
  
  @override
  Future<void> saveRecentLoginUrl(RecentLoginUrl recentLogin) {
    return _loginDataSource[DataSourceType.hiveCache]!.saveLoginUrl(recentLogin);
  }

  @override
  Future<List<RecentLoginUrl>> getAllRecentLoginUrlLatest({int? limit, String? pattern}) {
    return _loginDataSource[DataSourceType.hiveCache]!.getAllRecentLoginUrlLatest(limit: limit, pattern: pattern);
  }

  @override
  Future<List<RecentLoginUsername>> getAllRecentLoginUsernameLatest({int? limit, String? pattern}) {
    return _loginDataSource[DataSourceType.hiveCache]!.getAllRecentLoginUsernamesLatest(limit: limit, pattern: pattern);
  }

  @override
  Future<void> saveLoginUsername(RecentLoginUsername recentLoginUsername) {
    return _loginDataSource[DataSourceType.hiveCache]!.saveLoginUsername(recentLoginUsername);
  }

  @override
  Future<String> dnsLookupToGetJmapUrl(String emailAddress) {
    return _loginDataSource[DataSourceType.network]!.dnsLookupToGetJmapUrl(emailAddress);
  }
}