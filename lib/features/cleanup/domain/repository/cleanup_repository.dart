import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_url_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_username_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';

abstract class CleanupRepository {
  Future<void> cleanEmailCache(EmailCleanupRule cleanupRule);

  Future<void> cleanRecentSearchCache(RecentSearchCleanupRule cleanupRule);

  Future<void> cleanRecentLoginUrlCache(RecentLoginUrlCleanupRule cleanupRule);

  Future<void> cleanRecentLoginUsernameCache(RecentLoginUsernameCleanupRule cleanupRule);
}
