import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';

class GetAllRecentSearchLatestSuccess extends UIState {

  final List<RecentSearch> listRecentSearch;

  GetAllRecentSearchLatestSuccess(this.listRecentSearch);

  @override
  List<Object> get props => [listRecentSearch];
}

class GetAllRecentSearchLatestFailure extends FeatureFailure {

  GetAllRecentSearchLatestFailure(dynamic exception) : super(exception: exception);
}