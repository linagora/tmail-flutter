import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/presentation_email.dart';

class SearchingMoreState extends UIState {}

class SearchMoreEmailSuccess extends UIState {
  final List<PresentationEmail> emailList;

  SearchMoreEmailSuccess(this.emailList);

  @override
  List<Object> get props => [emailList];
}

class SearchMoreEmailFailure extends FeatureFailure {

  SearchMoreEmailFailure(dynamic exception) : super(exception: exception);
}