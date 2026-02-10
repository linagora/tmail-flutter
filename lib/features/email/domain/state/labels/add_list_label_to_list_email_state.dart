import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';

class AddingListLabelsToListEmails extends LoadingState {}

class AddListLabelsToListEmailsSuccess extends UIState {
  final List<EmailId> emailIds;
  final List<KeyWordIdentifier> labelKeywords;
  final List<String> labelDisplays;

  AddListLabelsToListEmailsSuccess(
    this.emailIds,
    this.labelKeywords,
    this.labelDisplays,
  );

  @override
  List<Object> get props => [emailIds, labelKeywords, labelDisplays];
}

class AddListLabelsToListEmailsHasSomeFailure
    extends AddListLabelsToListEmailsSuccess {
  AddListLabelsToListEmailsHasSomeFailure(
    super.emailIds,
    super.labelKeywords,
    super.labelDisplays,
  );

  @override
  List<Object> get props => [...super.props, 'hasSomeFailure'];
}

class AddListLabelsToListEmailsFailure extends FeatureFailure {
  final List<String> labelDisplays;

  AddListLabelsToListEmailsFailure({
    dynamic exception,
    required this.labelDisplays,
  }) : super(exception: exception);

  @override
  List<Object?> get props => [...super.props, labelDisplays];
}
