import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class ComposerArguments extends RouterArguments {
  final EmailActionType emailActionType;
  final PresentationEmail? presentationEmail;
  final String? emailContents;
  final List<SharedMediaFile>? listSharedMediaFile;
  final List<EmailAddress>? listEmailAddress;
  final List<Attachment>? attachments;
  final Role? mailboxRole;
  final SendingEmail? sendingEmail;
  final String? subject;
  final String? body;
  final MessageIdsHeaderValue? messageId;
  final MessageIdsHeaderValue? references;
  final EmailId? previousEmailId;
  final List<Identity>? identities;

  ComposerArguments({
    this.emailActionType = EmailActionType.compose,
    this.presentationEmail,
    this.emailContents,
    this.attachments,
    this.mailboxRole,
    this.listEmailAddress,
    this.listSharedMediaFile,
    this.sendingEmail,
    this.subject,
    this.body,
    this.messageId,
    this.references,
    this.previousEmailId,
    this.identities,
  });

  factory ComposerArguments.fromSendingEmail(SendingEmail sendingEmail) =>
    ComposerArguments(
      emailActionType: EmailActionType.editSendingEmail,
      sendingEmail: sendingEmail
    );

  factory ComposerArguments.fromContentShared(String content) =>
    ComposerArguments(
      emailActionType: EmailActionType.composeFromContentShared,
      emailContents: content
    );

  factory ComposerArguments.fromFileShared(List<SharedMediaFile> filesShared) =>
    ComposerArguments(
      emailActionType: EmailActionType.composeFromFileShared,
      listSharedMediaFile: filesShared
    );

  factory ComposerArguments.fromEmailAddress(EmailAddress emailAddress) =>
    ComposerArguments(
      emailActionType: EmailActionType.composeFromEmailAddress,
      listEmailAddress: [emailAddress]
    );

  factory ComposerArguments.fromMailtoUri({List<EmailAddress>? listEmailAddress, String? subject, String? body}) =>
    ComposerArguments(
      emailActionType: EmailActionType.composeFromMailtoUri,
      listEmailAddress: listEmailAddress,
      subject: subject,
      body: body,
    );

  factory ComposerArguments.editDraftEmail(PresentationEmail presentationEmail) =>
    ComposerArguments(
      emailActionType: EmailActionType.editDraft,
      presentationEmail: presentationEmail
    );

  factory ComposerArguments.fromSessionStorageBrowser(ComposerCache composerCache) =>
    ComposerArguments(
      emailActionType: EmailActionType.reopenComposerBrowser,
      presentationEmail: PresentationEmail(
        id: composerCache.id,
        subject: composerCache.subject,
        from: composerCache.from,
        to: composerCache.to,
        cc: composerCache.cc,
        bcc: composerCache.bcc,
      ),
      emailContents: composerCache.emailContentList.asHtmlString,
    );

  factory ComposerArguments.fromLocalStorageBrowser(Email email) =>
    ComposerArguments(
      emailActionType: EmailActionType.restoreComposedEmailFromLocalStorage,
      presentationEmail: email.toPresentationEmail(),
      attachments: email.allAttachments,
      emailContents: email.emailContentList.asHtmlString,
    );

  factory ComposerArguments.replyEmail({
    required PresentationEmail presentationEmail,
    required String content,
    Role? mailboxRole,
    MessageIdsHeaderValue? messageId,
    MessageIdsHeaderValue? references,
  }) => ComposerArguments(
    emailActionType: EmailActionType.reply,
    presentationEmail: presentationEmail,
    emailContents: content,
    mailboxRole: mailboxRole,
    messageId: messageId,
    references: references,
  );

  factory ComposerArguments.replyAllEmail({
    required PresentationEmail presentationEmail,
    required String content,
    Role? mailboxRole,
    MessageIdsHeaderValue? messageId,
    MessageIdsHeaderValue? references,
  }) => ComposerArguments(
    emailActionType: EmailActionType.replyAll,
    presentationEmail: presentationEmail,
    emailContents: content,
    mailboxRole: mailboxRole,
    messageId: messageId,
    references: references,
  );

  factory ComposerArguments.forwardEmail({
    required PresentationEmail presentationEmail,
    required String content,
    required List<Attachment> attachments,
    MessageIdsHeaderValue? messageId,
    MessageIdsHeaderValue? references,
  }) => ComposerArguments(
    emailActionType: EmailActionType.forward,
    presentationEmail: presentationEmail,
    emailContents: content,
    attachments: attachments,
    mailboxRole: presentationEmail.mailboxContain?.role,
    messageId: messageId,
    references: references,
  );

  SendingEmailActionType get sendingEmailActionType => sendingEmail != null
    ? SendingEmailActionType.edit
    : SendingEmailActionType.create;

  factory ComposerArguments.fromUnsubscribeMailtoLink({
    List<EmailAddress>? listEmailAddress,
    String? subject,
    String? body,
    EmailId? previousEmailId
  }) =>
    ComposerArguments(
      emailActionType: EmailActionType.composeFromUnsubscribeMailtoLink,
      listEmailAddress: listEmailAddress,
      subject: subject,
      body: body,
      previousEmailId: previousEmailId,
    );


  @override
  List<Object?> get props => [
    emailActionType,
    presentationEmail,
    emailContents,
    attachments,
    mailboxRole,
    listEmailAddress,
    listSharedMediaFile,
    sendingEmail,
    subject,
    body,
    messageId,
    references,
    identities,
  ];
}