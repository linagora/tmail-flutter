import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/auto_create_tag_for_recipients_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/get_draft_mailbox_id_for_composer_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/get_outbox_mailbox_id_for_composer_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/get_sent_mailbox_id_for_composer_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';

extension HandleLocalEmailDraftExtension on ComposerController {
  Future<CreateEmailRequest?> generateCreateEmailRequest() async {
    final arguments = composerArguments.value;
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;

    if (arguments == null || session == null || accountId == null) {
      log('HandleLocalEmailDraftExtension::generateCreateEmailRequest: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
      return null;
    }

    final emailContent = await getContentInEditor();
    final uploadUri = getUploadUriFromSession(session, accountId);

    final composerIndex = composerId != null
        ? mailboxDashBoardController.composerManager
            .getComposerIndex(composerId!)
        : null;

    return CreateEmailRequest(
      session: session,
      accountId: accountId,
      emailActionType: arguments.emailActionType,
      ownEmailAddress: ownEmailAddress,
      subject: subjectEmail.value ?? '',
      emailContent: emailContent,
      fromSender: arguments.presentationEmail?.from ?? {},
      toRecipients: listToEmailAddress.toSet(),
      ccRecipients: listCcEmailAddress.toSet(),
      bccRecipients: listBccEmailAddress.toSet(),
      replyToRecipients: listReplyToEmailAddress.toSet(),
      hasRequestReadReceipt: hasRequestReadReceipt.value,
      isMarkAsImportant: isMarkAsImportant.value,
      identity: identitySelected.value,
      attachments: uploadController.attachmentsUploaded,
      inlineAttachments: uploadController.mapInlineAttachments,
      outboxMailboxId: getOutboxMailboxIdForComposer(),
      sentMailboxId: getSentMailboxIdForComposer(),
      draftsMailboxId: getDraftMailboxIdForComposer(),
      draftsEmailId: getDraftEmailId(),
      answerForwardEmailId: arguments.presentationEmail?.id,
      unsubscribeEmailId: arguments.previousEmailId,
      messageId: arguments.messageId,
      references: arguments.references,
      emailSendingQueue: arguments.sendingEmail,
      displayMode: screenDisplayMode.value,
      uploadUri: uploadUri,
      composerIndex: composerIndex,
      composerId: composerId,
    );
  }

  Future<void> saveLocalEmailDraftAction() async {
    final username = mailboxDashBoardController.sessionCurrent?.username;
    final accountId = mailboxDashBoardController.accountId.value;

    if (username == null ||
        accountId == null ||
        saveLocalEmailDraftInteractor == null) {
      return;
    }

    autoCreateEmailTag();

    final createEmailRequest = await generateCreateEmailRequest();
    if (createEmailRequest == null) return;

    await saveLocalEmailDraftInteractor!.execute(
      createEmailRequest,
      accountId,
      username,
    );
  }
}
