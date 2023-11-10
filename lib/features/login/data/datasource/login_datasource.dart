import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';

abstract class LoginDataSource {
  Future<void> saveLoginUrl(RecentLoginUrl baseUrl);

  Future<void> saveLoginUsername(RecentLoginUsername username);

  Future<List<RecentLoginUrl>> getAllRecentLoginUrlLatest({int? limit, String? pattern});

  Future<List<RecentLoginUsername>> getAllRecentLoginUsernamesLatest({int? limit, String? pattern});

  Future<String> dnsLookupToGetJmapUrl(String emailAddress);
}