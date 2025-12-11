import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';

class AddingALabelToAnEmail extends LoadingState {}

class AddALabelToAnEmailSuccess extends UIState {
  final EmailId emailId;
  final KeyWordIdentifier labelKeyword;
  final String labelDisplay;

  AddALabelToAnEmailSuccess(this.emailId, this.labelKeyword, this.labelDisplay);

  @override
  List<Object> get props => [emailId, labelKeyword, labelDisplay];
}

class AddALabelToAnEmailFailure extends FeatureFailure {
  final String labelDisplay;

  AddALabelToAnEmailFailure({
    dynamic exception,
    required this.labelDisplay,
  }) : super(exception: exception);

  @override
  List<Object?> get props => [...super.props, labelDisplay];
}
