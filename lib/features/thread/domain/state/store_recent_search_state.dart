import 'package:core/core.dart';
import 'package:tmail_ui_user/features/thread/data/model/recent_search_hive_cache.dart';

class StoreRecentSearchSuccess extends UIState {
  final List<RecentSearchHiveCache> recentSearchs;

  StoreRecentSearchSuccess(this.recentSearchs);

  @override
  List<Object?> get props => [recentSearchs];
}

class StoreRecentSearchSuccessFailure extends FeatureFailure {
  final dynamic exception;

  StoreRecentSearchSuccessFailure(this.exception);

  @override
  List<Object> get props => [exception];
}
