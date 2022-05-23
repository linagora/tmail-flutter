import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';

abstract class SearchDataSource {
  Future<void> saveRecentSearch(RecentSearch recentSearch);

  Future<List<RecentSearch>> getAllRecentSearchLatest({int? limit, String? pattern});
}