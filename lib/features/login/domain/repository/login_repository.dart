import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';

abstract class LoginRepository {
  Future<void> saveRecentLoginUrl(RecentLoginUrl recentLoginUrl);

  Future<void> saveLoginUsername(RecentLoginUsername recentLoginUsername);

  Future<List<RecentLoginUsername>> getAllRecentLoginUsernameLatest({int? limit, String? pattern});

  Future<List<RecentLoginUrl>> getAllRecentLoginUrlLatest({int? limit, String? pattern});

  Future<String> dnsLookupToGetJmapUrl(String emailAddress);
}