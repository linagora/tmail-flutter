import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';

abstract class LoginUrlRepository {
  Future<void> saveRecentLoginUrl(RecentLoginUrl recentLoginUrl);
}