import 'package:core/core.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/username_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_attachments_extension.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/extensions/sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_arguments.dart';

extension CreateEmailRequestExtension on CreateEmailRequest {

  Set<EmailAddress> createSenders() {
    if (identity?.email?.isNotEmpty == true) {
      return { identity!.toEmailAddress() };
    } else {
      return { session.username.toEmailAddress() };
    }
  }

  String createMdnEmailAddress() {
    if (emailActionType == EmailActionType.editDraft && fromSender.isNotEmpty) {
      return fromSender.first.emailAddress;
    } else {
      return session.username.value;
    }
  }

  Set<EmailAddress> createReplyToRecipients() {
    if (identity?.replyTo?.isNotEmpty == true) {
      return identity!.replyTo!.toSet();
    } else {
      return { session.username.toEmailAddress() };
    }
  }

  Set<EmailBodyPart> createAttachments() => attachments?.toEmailBodyPart() ?? {};

  Map<KeyWordIdentifier, bool>? createKeywords() {
    if (draftsMailboxId != null) {
      return {
        KeyWordIdentifier.emailDraft: true,
        KeyWordIdentifier.emailSeen: true,
      };
    } else {
      return null;
    }
  }

  Map<MailboxId, bool>? createMailboxIds() {
    if (draftsMailboxId != null || outboxMailboxId != null) {
      return {
        if (draftsMailboxId != null)
          draftsMailboxId!: true,
        if (outboxMailboxId != null)
          outboxMailboxId!: true,
      };
    } else {
      return null;
    }
  }

  MessageIdsHeaderValue? createInReplyTo() {
    if (emailActionType == EmailActionType.reply ||
        emailActionType == EmailActionType.replyAll
    ) {
      return messageId;
    }
    return null;
  }

  MessageIdsHeaderValue? createReferences() {
    if (emailActionType == EmailActionType.reply ||
        emailActionType == EmailActionType.replyAll ||
        emailActionType == EmailActionType.forward
    ) {
      Set<String> ids = {};
      if (messageId?.ids.isNotEmpty == true) {
        ids.addAll(messageId!.ids);
      }
      if (references?.ids.isNotEmpty == true) {
        ids.addAll(references!.ids);
      }
      if (ids.isNotEmpty) {
        return MessageIdsHeaderValue(ids);
      }
    }
    return null;
  }

  Email generateEmail({
    required String newEmailContent,
    required Set<EmailBodyPart> newEmailAttachments,
    required String userAgent,
    required PartId partId,
  }) {
    return Email(
      mailboxIds: createMailboxIds(),
      from: createSenders(),
      to: toRecipients,
      cc: ccRecipients,
      bcc: bccRecipients,
      replyTo: createReplyToRecipients(),
      inReplyTo: createInReplyTo(),
      references: createReferences(),
      keywords: createKeywords(),
      subject: subject,
      htmlBody: {
        EmailBodyPart(
          partId: partId,
          type: MediaType.parse(Constant.textHtmlMimeType)
        )
      },
      bodyValues: {
        partId: EmailBodyValue(
          newEmailContent,
          false,
          false
        )
      },
      headerUserAgent: {
        IndividualHeaderIdentifier.headerUserAgent : userAgent
      },
      attachments: newEmailAttachments.isNotEmpty
        ? newEmailAttachments
        : null,
      headerMdn: isRequestReadReceipt
        ? { IndividualHeaderIdentifier.headerMdn: createMdnEmailAddress() }
        : null,
    );
  }

  EmailRequest createEmailRequest({required Email emailObject}) {
    if (emailActionType == EmailActionType.editSendingEmail) {
      return emailSendingQueue!.toEmailRequest(newEmail: emailObject);
    } else {
      return EmailRequest(
        email: emailObject,
        sentMailboxId: sentMailboxId,
        identityId: identity?.id,
        emailIdDestroyed: draftsEmailId,
        emailIdAnsweredOrForwarded: answerForwardEmailId,
        emailActionType: emailActionType,
        previousEmailId: unsubscribeEmailId,
      );
    }
  }

  CreateNewMailboxRequest? createMailboxRequest() {
    if (outboxMailboxId == null) {
      return CreateNewMailboxRequest(MailboxName(PresentationMailbox.outboxRole.inCaps));
    } else {
      return null;
    }
  }

  SendingEmailArguments toSendingEmailArguments({required Email emailObject}) {
    return SendingEmailArguments(
      session,
      accountId,
      createEmailRequest(emailObject: emailObject),
      createMailboxRequest()
    );
  }
}