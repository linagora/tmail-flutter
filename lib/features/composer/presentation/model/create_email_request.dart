
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';

class CreateEmailRequest with EquatableMixin {

  final Session session;
  final AccountId accountId;
  final EmailActionType emailActionType;
  final String subject;
  final String emailContent;
  final bool hasRequestReadReceipt;
  final bool isMarkAsImportant;
  final Set<EmailAddress>? fromSender;
  final Set<EmailAddress>? toRecipients;
  final Set<EmailAddress>? ccRecipients;
  final Set<EmailAddress>? bccRecipients;
  final Set<EmailAddress>? replyToRecipients;
  final Identity? identity;
  final List<Attachment>? attachments;
  final Map<String, Attachment>? inlineAttachments;
  final MailboxId? outboxMailboxId;
  final MailboxId? sentMailboxId;
  final MailboxId? draftsMailboxId;
  final EmailId? draftsEmailId;
  final EmailId? answerForwardEmailId;
  final EmailId? unsubscribeEmailId;
  final MessageIdsHeaderValue? messageId;
  final MessageIdsHeaderValue? references;
  final SendingEmail? emailSendingQueue;
  final ScreenDisplayMode displayMode;

  CreateEmailRequest({
    required this.session,
    required this.accountId,
    required this.emailActionType,
    required this.subject,
    required this.emailContent,
    this.fromSender,
    this.toRecipients,
    this.ccRecipients,
    this.bccRecipients,
    this.replyToRecipients,
    this.hasRequestReadReceipt = true,
    this.isMarkAsImportant = false,
    this.identity,
    this.attachments,
    this.inlineAttachments,
    this.outboxMailboxId,
    this.sentMailboxId,
    this.draftsMailboxId,
    this.draftsEmailId,
    this.answerForwardEmailId,
    this.unsubscribeEmailId,
    this.messageId,
    this.references,
    this.emailSendingQueue,
    this.displayMode = ScreenDisplayMode.normal
  });

  @override
  List<Object?> get props => [
    session,
    accountId,
    emailActionType,
    subject,
    emailContent,
    fromSender,
    toRecipients,
    ccRecipients,
    bccRecipients,
    replyToRecipients,
    identity,
    hasRequestReadReceipt,
    isMarkAsImportant,
    attachments,
    inlineAttachments,
    outboxMailboxId,
    sentMailboxId,
    draftsMailboxId,
    draftsEmailId,
    answerForwardEmailId,
    unsubscribeEmailId,
    references,
    references,
    emailSendingQueue,
    displayMode,
  ];
}