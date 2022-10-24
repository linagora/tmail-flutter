
import 'package:tmail_ui_user/features/cleanup/data/datasource/cleanup_datasource.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_url_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_username_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/repository/cleanup_repository.dart';

class CleanupRepositoryImpl extends CleanupRepository {

  final CleanupDataSource cleanupDataSource;

  CleanupRepositoryImpl(this.cleanupDataSource);

  @override
  Future<void> cleanEmailCache(EmailCleanupRule cleanupRule) {
    return cleanupDataSource.cleanEmailCache(cleanupRule);
  }

  @override
  Future<void> cleanRecentSearchCache(RecentSearchCleanupRule cleanupRule) {
    return cleanupDataSource.cleanRecentSearchCache(cleanupRule);
  }

  @override
  Future<void> cleanRecentLoginUrlCache(RecentLoginUrlCleanupRule cleanupRule) {
    return cleanupDataSource.cleanRecentLoginUrlCache(cleanupRule);
  }

  @override
  Future<void> cleanRecentLoginUsernameCache(RecentLoginUsernameCleanupRule cleanupRule) {
    return cleanupDataSource.cleanRecentLoginUsernameCache(cleanupRule);
  }
}