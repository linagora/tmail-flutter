import 'package:core/core.dart';
import 'package:tmail_ui_user/features/thread/data/model/recent_search_hive_cache.dart';

class GetRecentSearchSuccess extends UIState {
  final List<RecentSearchHiveCache> recentSearchs;

  GetRecentSearchSuccess(this.recentSearchs);

  @override
  List<Object?> get props => [recentSearchs];
}

class GetRecentSearchFailure extends FeatureFailure {
  final dynamic exception;

  GetRecentSearchFailure(this.exception);

  @override
  List<Object> get props => [exception];
}