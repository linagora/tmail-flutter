import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

enum SubfoldersDeleteStatus { none, allDeleted, someDeleted, failed }

sealed class EmptyFolderState {
  const EmptyFolderState();
}

class EmptyFolderIdle extends EmptyFolderState {
  const EmptyFolderIdle();
}

class EmptyFolderLoading extends EmptyFolderState {
  const EmptyFolderLoading();
}

class EmptyFolderSuccess extends EmptyFolderState {
  final List<EmailId> clearedEmailIds;
  final MailboxId mailboxId;
  final SubfoldersDeleteStatus subfoldersStatus;

  const EmptyFolderSuccess({
    required this.clearedEmailIds,
    required this.mailboxId,
    this.subfoldersStatus = SubfoldersDeleteStatus.none,
  });
}

class EmptyFolderInProgress extends EmptyFolderState {
  final MailboxId mailboxId;
  final int countEmailsDeleted;
  final int totalEmails;

  const EmptyFolderInProgress({
    required this.mailboxId,
    required this.countEmailsDeleted,
    required this.totalEmails,
  });
}

class EmptyFolderFailure extends EmptyFolderState {
  final Object? exception;
  final MailboxId mailboxId;

  const EmptyFolderFailure({this.exception, required this.mailboxId});
}
