import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';

abstract class SearchDataSource {
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
}