
import 'package:tmail_ui_user/features/cleanup/data/datasource/cleanup_datasource.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
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
}