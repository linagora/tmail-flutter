import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/presentation_email.dart';

class QuickSearchEmailSuccess extends UIState {
  final List<PresentationEmail> emailList;

  QuickSearchEmailSuccess(this.emailList);

  @override
  List<Object> get props => [emailList];
}

class QuickSearchEmailFailure extends FeatureFailure {

  QuickSearchEmailFailure(dynamic exception) : super(exception: exception);
}