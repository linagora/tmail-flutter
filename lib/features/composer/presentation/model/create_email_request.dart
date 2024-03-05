
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';

class CreateEmailRequest with EquatableMixin {

  final Session session;
  final AccountId accountId;
  final EmailActionType emailActionType;
  final String subject;
  final String emailContent;
  final bool isRequestReadReceipt;
  final Set<EmailAddress> fromSender;
  final Set<EmailAddress> toRecipients;
  final Set<EmailAddress> ccRecipients;
  final Set<EmailAddress> bccRecipients;
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

  CreateEmailRequest({
    required this.session,
    required this.accountId,
    required this.emailActionType,
    required this.subject,
    required this.emailContent,
    required this.fromSender,
    required this.toRecipients,
    required this.ccRecipients,
    required this.bccRecipients,
    this.isRequestReadReceipt = true,
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
    this.emailSendingQueue
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
    identity,
    isRequestReadReceipt,
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
    emailSendingQueue
  ];
}