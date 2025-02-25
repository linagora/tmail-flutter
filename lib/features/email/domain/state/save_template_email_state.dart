import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class SavingTemplateEmail extends LoadingState {}

class SaveTemplateEmailSuccess extends UIState {
  SaveTemplateEmailSuccess(this.emailId);

  final EmailId emailId;

  @override
  List<Object> get props => [emailId];
}

class SaveTemplateEmailFailure extends FeatureFailure {
  SaveTemplateEmailFailure({super.exception});
}