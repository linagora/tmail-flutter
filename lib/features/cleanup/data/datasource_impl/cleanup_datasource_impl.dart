
import 'package:tmail_ui_user/features/cleanup/data/datasource/cleanup_datasource.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_search_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';

class CleanupDataSourceImpl extends CleanupDataSource {

  final EmailCacheManager emailCacheManager;
  final RecentSearchCacheManager recentSearchCacheManager;

  CleanupDataSourceImpl(this.emailCacheManager, this.recentSearchCacheManager);

  @override
  Future<void> cleanEmailCache(EmailCleanupRule cleanupRule) {
    return Future.sync(() async {
      return await emailCacheManager.clean(cleanupRule);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> cleanRecentSearchCache(RecentSearchCleanupRule cleanupRule) {
    return Future.sync(() async {
      return await recentSearchCacheManager.clean(cleanupRule);
    }).catchError((error) {
      throw error;
    });
  }
}