
import 'package:tmail_ui_user/features/cleanup/data/datasource/cleanup_datasource.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_login_url_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_login_username_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_search_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_url_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_username_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class CleanupDataSourceImpl extends CleanupDataSource {

  final EmailCacheManager emailCacheManager;
  final RecentSearchCacheManager recentSearchCacheManager;
  final RecentLoginUrlCacheManager recentLoginUrlCacheManager;
  final RecentLoginUsernameCacheManager recentLoginUsernameCacheManager;
  final ExceptionThrower _exceptionThrower;

  CleanupDataSourceImpl(
    this.emailCacheManager,
    this.recentSearchCacheManager,
    this.recentLoginUrlCacheManager,
    this.recentLoginUsernameCacheManager,
    this._exceptionThrower
  );

  @override
  Future<void> cleanEmailCache(EmailCleanupRule cleanupRule) {
    return Future.sync(() async {
      return await emailCacheManager.clean(cleanupRule);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> cleanRecentSearchCache(RecentSearchCleanupRule cleanupRule) {
    return Future.sync(() async {
      return await recentSearchCacheManager.clean(cleanupRule);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> cleanRecentLoginUrlCache(RecentLoginUrlCleanupRule cleanupRule) {
    return Future.sync(() async {
      return await recentLoginUrlCacheManager.clean(cleanupRule);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> cleanRecentLoginUsernameCache(RecentLoginUsernameCleanupRule cleanupRule) {
    return Future.sync(() async {
      return await recentLoginUsernameCacheManager.clean(cleanupRule);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}