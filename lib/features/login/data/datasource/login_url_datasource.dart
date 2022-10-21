import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';

abstract class LoginUrlDataSource {
  Future<void> saveLoginUrl(RecentLoginUrl baseUrl);

  Future<List<RecentLoginUrl>> getAllRecentLoginUrlLatest({int? limit, String? pattern});
}