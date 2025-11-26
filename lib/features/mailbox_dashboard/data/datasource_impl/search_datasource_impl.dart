
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_search_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/search_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/local_sort_order_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class SearchDataSourceImpl extends SearchDataSource {

  final RecentSearchCacheManager _recentSearchCacheManager;
  final LocalSortOrderManager _localSortOrderManager;
  final ExceptionThrower _exceptionThrower;

  SearchDataSourceImpl(
    this._recentSearchCacheManager,
    this._localSortOrderManager,
    this._exceptionThrower,
  );

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
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
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
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> storeEmailSortOrder(EmailSortOrderType sortOrderType) {
    return Future.sync(() async {
      return await _localSortOrderManager.storeEmailSortOrderIfChanged(sortOrderType);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<EmailSortOrderType> getStoredEmailSortOrder() {
    return Future.sync(() {
      return _localSortOrderManager.getStoredEmailSortOrder();
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}