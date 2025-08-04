
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/search_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/search_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';

class SearchRepositoryImpl extends SearchRepository {

  final SearchDataSource searchDataSource;

  SearchRepositoryImpl(this.searchDataSource);

  @override
  Future<void> saveRecentSearch(
    AccountId accountId,
    UserName userName,
    RecentSearch recentSearch,
  ) {
    return searchDataSource.saveRecentSearch(accountId, userName, recentSearch);
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
    return searchDataSource.getAllRecentSearchLatest(
      accountId,
      userName,
      limit: limit,
      pattern: pattern,
    );
  }

  @override
  Future<void> storeEmailSortOrder(EmailSortOrderType sortOrderType) {
    return searchDataSource.storeEmailSortOrder(sortOrderType);
  }

  @override
  Future<EmailSortOrderType> getStoredEmailSortOrder() {
    return searchDataSource.getStoredEmailSortOrder();
  }
}