import 'package:tmail_ui_user/features/reactions/data/datasource/reactions_datasource.dart';
import 'package:tmail_ui_user/features/reactions/domain/repository/reactions_repository.dart';

class ReactionsRepositoryImpl implements ReactionsRepository {
  final ReactionsDatasource _dataSource;

  ReactionsRepositoryImpl(this._dataSource);

  @override
  Future<List<String>> getRecentReactions() {
    return _dataSource.getRecentReactions();
  }

  @override
  Future<void> storeRecentReactions(List<String> recentReactions) {
    return _dataSource.storeRecentReactions(recentReactions);
  }
}
