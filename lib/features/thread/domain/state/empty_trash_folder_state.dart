import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class EmptyTrashFolderLoading extends LoadingState {}

class EmptyTrashFolderSuccess extends UIState {

  final List<EmailId> emailIds;
  final MailboxId? mailboxId;

  EmptyTrashFolderSuccess(this.emailIds, this.mailboxId);

  @override
  List<Object?> get props => [emailIds, mailboxId];
}

class EmptyTrashFolderFailure extends FeatureFailure {

  EmptyTrashFolderFailure(dynamic exception) : super(exception: exception);
}