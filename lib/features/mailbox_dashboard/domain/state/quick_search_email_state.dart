
import 'package:core/core.dart';
import 'package:model/email/presentation_email.dart';

class QuickSearchEmailSuccess extends UIState {
  final List<PresentationEmail> emailList;

  QuickSearchEmailSuccess(this.emailList);

  @override
  List<Object> get props => [emailList];
}

class QuickSearchEmailFailure extends FeatureFailure {
  final dynamic exception;

  QuickSearchEmailFailure(this.exception);

  @override
  List<Object> get props => [exception];
}