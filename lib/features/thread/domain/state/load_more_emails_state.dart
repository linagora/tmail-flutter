import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/presentation_email.dart';

class LoadMoreEmailsSuccess extends UIState {
  final List<PresentationEmail> emailList;

  LoadMoreEmailsSuccess(this.emailList);

  @override
  List<Object?> get props => [emailList];
}

class LoadMoreEmailsFailure extends FeatureFailure {

  LoadMoreEmailsFailure(dynamic exception) : super(exception: exception);
}