import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/presentation_email.dart';

class SearchingState extends LoadingState {}

class RefreshingSearchState extends LoadingState {}

class SearchEmailSuccess extends UIState {
  final List<PresentationEmail> emailList;

  SearchEmailSuccess(this.emailList);

  @override
  List<Object> get props => [emailList];
}

class SearchEmailFailure extends FeatureFailure {

  SearchEmailFailure(dynamic exception) : super(exception: exception);
}