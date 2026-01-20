import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';

class AddingALabelToAThread extends LoadingState {}

class AddALabelToAThreadSuccess extends UIState {
  final List<EmailId> emailIds;
  final KeyWordIdentifier labelKeyword;
  final String labelDisplay;

  AddALabelToAThreadSuccess(this.emailIds, this.labelKeyword, this.labelDisplay);

  @override
  List<Object> get props => [emailIds, labelKeyword, labelDisplay];
}

class AddALabelToAThreadFailure extends FeatureFailure {
  final String labelDisplay;

  AddALabelToAThreadFailure({
    dynamic exception,
    required this.labelDisplay,
  }) : super(exception: exception);

  @override
  List<Object?> get props => [...super.props, labelDisplay];
}
