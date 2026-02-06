import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';

class RemovingALabelFromAnEmail extends LoadingState {}

class RemoveALabelFromAnEmailSuccess extends UIState {
  final EmailId emailId;
  final KeyWordIdentifier labelKeyword;
  final String labelDisplay;

  RemoveALabelFromAnEmailSuccess(this.emailId, this.labelKeyword, this.labelDisplay);

  @override
  List<Object> get props => [emailId, labelKeyword, labelDisplay];
}

class RemoveALabelFromAnEmailFailure extends FeatureFailure {
  final String labelDisplay;

  RemoveALabelFromAnEmailFailure({
    dynamic exception,
    required this.labelDisplay,
  }) : super(exception: exception);

  @override
  List<Object?> get props => [...super.props, labelDisplay];
}
