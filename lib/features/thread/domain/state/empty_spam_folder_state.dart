import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class EmptySpamFolderLoading extends LoadingState {}

class EmptySpamFolderSuccess extends UIState {

  final List<EmailId> emailIds;

  EmptySpamFolderSuccess(this.emailIds);

  @override
  List<Object?> get props => [emailIds];
}

class EmptySpamFolderFailure extends FeatureFailure {

  EmptySpamFolderFailure(dynamic exception) : super(exception: exception);
}

class EmptyingFolderState extends UIState {
  final MailboxId mailboxId;
  final int countEmailsDeleted;
  final int totalEmails;

  EmptyingFolderState(this.mailboxId, this.countEmailsDeleted, this.totalEmails);

  @override
  List<Object?> get props => [mailboxId, countEmailsDeleted, totalEmails];
}