
import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';

class SearchState with EquatableMixin {
  final SearchStatus searchStatus;

  SearchState(this.searchStatus);

  factory SearchState.initial() {
    return SearchState(SearchStatus.INACTIVE);
  }

  SearchState disableSearchState() {
    return SearchState(SearchStatus.INACTIVE);
  }

  SearchState enableSearchState() {
    return SearchState(SearchStatus.ACTIVE);
  }

  @override
  List<Object?> get props => [searchStatus];
}