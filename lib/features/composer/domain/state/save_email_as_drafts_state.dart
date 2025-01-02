import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class SaveEmailAsDraftsLoading extends LoadingState {}

class SaveEmailAsDraftsSuccess extends UIState {

  final EmailId emailId;
  final MailboxId? draftMailboxId;

  SaveEmailAsDraftsSuccess(this.emailId, this.draftMailboxId);

  @override
  List<Object?> get props => [emailId, draftMailboxId, ...super.props];
}

class SaveEmailAsDraftsFailure extends FeatureFailure {

  SaveEmailAsDraftsFailure(dynamic exception) : super(exception: exception);
}

class CancelSavingEmailToDrafts extends LoadingState {}