import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';

class ThreadDetailUIAction extends UIAction {
  @override
  List<Object?> get props => [];
}

class UpdatedEmailKeywordsAction extends ThreadDetailUIAction {
  UpdatedEmailKeywordsAction(
    this.emailId,
    this.updatedKeyword,
    this.value,
  );

  final EmailId emailId;
  final KeyWordIdentifier updatedKeyword;
  final bool value;

  @override
  List<Object?> get props => [emailId, updatedKeyword, value];
}

class UpdatedThreadDetailSettingAction extends ThreadDetailUIAction {}

class EmailMovedAction extends ThreadDetailUIAction {
  EmailMovedAction({
    required this.emailId,
    required this.originalMailboxId,
    required this.targetMailboxId,
  });

  final EmailId emailId;
  final MailboxId originalMailboxId;
  final MailboxId targetMailboxId;

  @override
  List<Object?> get props => [emailId, originalMailboxId, targetMailboxId];
}

class LoadThreadDetailAfterSelectedEmailAction extends ThreadDetailUIAction {
  LoadThreadDetailAfterSelectedEmailAction(this.threadId);

  final ThreadId threadId;

  @override
  List<Object?> get props => [threadId];
}