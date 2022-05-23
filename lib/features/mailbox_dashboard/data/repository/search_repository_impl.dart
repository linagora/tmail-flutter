
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/search_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/search_repository.dart';

class SearchRepositoryImpl extends SearchRepository {

  final SearchDataSource searchDataSource;

  SearchRepositoryImpl(this.searchDataSource);

  @override
  Future<void> saveRecentSearch(RecentSearch recentSearch) {
    return searchDataSource.saveRecentSearch(recentSearch);
  }
}