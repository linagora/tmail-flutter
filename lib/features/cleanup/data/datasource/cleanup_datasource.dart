
import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';

abstract class CleanupDataSource {
  Future<void> cleanEmailCache(EmailCleanupRule cleanupRule);

  Future<void> cleanRecentSearchCache(RecentSearchCleanupRule cleanupRule);
}