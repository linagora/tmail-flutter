import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';

class RemovingALabelFromAThread extends LoadingState {}

class RemoveALabelFromAThreadSuccess extends UIState {
  final List<EmailId> emailIds;
  final KeyWordIdentifier labelKeyword;
  final String labelDisplay;

  RemoveALabelFromAThreadSuccess(
    this.emailIds,
    this.labelKeyword,
    this.labelDisplay,
  );

  @override
  List<Object> get props => [emailIds, labelKeyword, labelDisplay];
}

class RemoveALabelFromAThreadFailure extends FeatureFailure {
  final String labelDisplay;

  RemoveALabelFromAThreadFailure({
    dynamic exception,
    required this.labelDisplay,
  }) : super(exception: exception);

  @override
  List<Object?> get props => [...super.props, labelDisplay];
}
