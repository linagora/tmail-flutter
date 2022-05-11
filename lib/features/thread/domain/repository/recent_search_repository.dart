
import 'package:tmail_ui_user/features/thread/domain/model/recent_search.dart';

abstract class RecentSearchRepository {

  Future<List<RecentSearch>> getAll(String? keyword);

  Future<bool> storeKeyword(String? keyword);
  
}