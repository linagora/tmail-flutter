import 'package:tmail_ui_user/features/thread/data/datasource/recent_search_datasource.dart';
import 'package:tmail_ui_user/features/thread/domain/model/recent_search.dart';

class HiveRecentSearchDataSource implements RecentSearchDataSource {
  @override
  Future<List<RecentSearch>> getAll(String? keyword) {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<bool> storeKeyword(String? keyword) {
    // TODO: implement storeKeyword
    throw UnimplementedError();
  }

}