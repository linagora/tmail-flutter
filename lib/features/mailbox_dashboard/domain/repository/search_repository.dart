
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';

abstract class SearchRepository {
  Future<void> saveRecentSearch(
    AccountId accountId,
    UserName userName,
    RecentSearch recentSearch,
  );

  Future<List<RecentSearch>> getAllRecentSearchLatest(
    AccountId accountId,
    UserName userName,
    {
      int? limit,
      String? pattern,
    }
  );

  Future<void> storeEmailSortOrder(EmailSortOrderType sortOrderType);

  Future<EmailSortOrderType> getStoredEmailSortOrder();
}