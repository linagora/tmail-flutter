import 'package:core/core.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';

class GetAllRecentSearchLatestSuccess extends UIState {

  final List<RecentSearch> listRecentSearch;

  GetAllRecentSearchLatestSuccess(this.listRecentSearch);

  @override
  List<Object> get props => [listRecentSearch];
}

class GetAllRecentSearchLatestFailure extends FeatureFailure {
  final dynamic exception;

  GetAllRecentSearchLatestFailure(this.exception);

  @override
  List<Object> get props => [exception];
}