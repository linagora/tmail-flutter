
import 'package:core/core.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

class SearchingState extends UIState {

  SearchingState();

  @override
  List<Object> get props => [];
}

class SearchEmailNewQuery extends UIState {
  final SearchQuery searchQuery;

  SearchEmailNewQuery(this.searchQuery);

  @override
  List<Object> get props => [searchQuery];
}

class SearchEmailSuccess extends UIState {
  final List<PresentationEmail> emailList;

  SearchEmailSuccess(this.emailList);

  @override
  List<Object> get props => [emailList];
}

class SearchEmailFailure extends FeatureFailure {
  final dynamic exception;

  SearchEmailFailure(this.exception);

  @override
  List<Object> get props => [exception];
}