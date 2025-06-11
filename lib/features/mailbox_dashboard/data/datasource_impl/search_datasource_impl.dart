
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_search_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/search_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class SearchDataSourceImpl extends SearchDataSource {

  final RecentSearchCacheManager _recentSearchCacheManager;
  final ExceptionThrower _exceptionThrower;

  SearchDataSourceImpl(this._recentSearchCacheManager, this._exceptionThrower);

  @override
  Future<void> saveRecentSearch(
    AccountId accountId,
    UserName userName,
    RecentSearch recentSearch,
  ) {
    return Future.sync(() async {
      return await _recentSearchCacheManager.saveRecentSearch(
        accountId,
        userName,
        recentSearch,
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<RecentSearch>> getAllRecentSearchLatest(
    AccountId accountId,
    UserName userName,
    {
      int? limit,
      String? pattern,
    }
  ) {
    return Future.sync(() async {
      return await _recentSearchCacheManager.getAllLatest(
        accountId,
        userName,
        limit: limit,
        pattern: pattern,
      );
    }).catchError(_exceptionThrower.throwException);
  }
}