import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';

abstract class LoginUsernameRepository {
  Future<void> saveLoginUsername(RecentLoginUsername recentLoginUsername);

  Future<List<RecentLoginUsername>> getAllRecentLoginUsernameLatest({int? limit, String? pattern});
}