
import 'package:core/core.dart';
import 'package:model/email/presentation_email.dart';

class SearchingMoreState extends UIState {

  SearchingMoreState();

  @override
  List<Object> get props => [];
}


class SearchMoreEmailSuccess extends UIState {
  final List<PresentationEmail> emailList;

  SearchMoreEmailSuccess(this.emailList);

  @override
  List<Object> get props => [emailList];
}

class SearchMoreEmailFailure extends FeatureFailure {
  final dynamic exception;

  SearchMoreEmailFailure(this.exception);

  @override
  List<Object> get props => [exception];
}