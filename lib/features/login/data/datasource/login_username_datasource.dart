import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';

abstract class LoginUsernameDataSource {
  Future<void> saveLoginUsername(RecentLoginUsername username);

  Future<List<RecentLoginUsername>> getAllRecentLoginUsernamesLatest({int? limit, String? pattern});
}