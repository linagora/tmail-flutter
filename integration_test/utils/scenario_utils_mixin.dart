import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/upload/file_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';

import '../models/provisioning_email.dart';

mixin ScenarioUtilsMixin {
  Future<void> provisionEmail(List<ProvisioningEmail> provisioningEmails) async {
    ComposerBindings().dependencies();

    final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
    final createNewAndSendEmailInteractor = Get.find<CreateNewAndSendEmailInteractor>();
    final threadController = Get.find<ThreadController>();

    final identity = await getIdentity();

    if (identity == null) return;

    // Provision emails
    await Future.wait(provisioningEmails.map((provisioningEmail) async {
      final attachments = await uploadAttachments(provisioningEmail.attachmentPaths);

      // Create and send email
      return await createNewAndSendEmailInteractor.execute(
        createEmailRequest: CreateEmailRequest(
          session: mailboxDashBoardController.sessionCurrent!,
          accountId: mailboxDashBoardController.accountId.value!,
          emailActionType: EmailActionType.compose,
          subject: provisioningEmail.subject,
          emailContent: provisioningEmail.content,
          fromSender: {},
          toRecipients: {EmailAddress(null, provisioningEmail.toEmail)},
          ccRecipients: {},
          bccRecipients: {},
          replyToRecipients: {},
          outboxMailboxId: mailboxDashBoardController.outboxMailbox?.mailboxId,
          sentMailboxId: mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleSent],
          identity: identity,
          attachments: attachments,
        ),
      ).last;
    }));

    // Refresh view after provisioning emails
    threadController.refreshAllEmail();

    ComposerBindings().dispose();
  }

  Future<File> preparingTxtFile(String content) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/test.txt');
    return file.writeAsString(content);
  }

  Future<List<Attachment>> uploadAttachments(
    List<String> attachmentPaths
  ) async {
    final mailboxDashBoardController = Get.find<MailboxDashBoardController>();

    final attachments = <Attachment>[];
    for (final path in attachmentPaths) {
      final file = File(path);
      final fileName = path.split('/').last;

      final fileInfo = FileInfo(
        fileName: fileName,
        filePath: path,
        fileSize: await file.length(),
      );
      final uploadUri = mailboxDashBoardController.sessionCurrent!.getUploadUri(
        mailboxDashBoardController.accountId.value!,
        jmapUrl: mailboxDashBoardController.dynamicUrlInterceptors.jmapUrl,
      );
      
      final uploadAttachmentInteractor = Get.find<UploadAttachmentInteractor>();
      final uploadAttachmentState = await uploadAttachmentInteractor
        .execute(fileInfo, uploadUri)
        .last;
      final attachment = await uploadAttachmentState.fold(
        (failure) => null,
        (success) async {
          if (success is UploadAttachmentSuccess) {
            final uploadAttachment = await success.uploadAttachment.progressState.last;
            return uploadAttachment.fold(
              (failure) => null,
              (success) {
                if (success is! SuccessAttachmentUploadState) return null;

                return success.attachment;
              },
            );
          }
        },
      );
      if (attachment != null) {
        attachments.add(attachment);
      }
    }

    return attachments;
  }

  Future<Identity?> getIdentity() async {
    final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
    final getAllIdentitiesInteractor = Get.find<GetAllIdentitiesInteractor>();
    final getAllIdentities = await getAllIdentitiesInteractor.execute(
      mailboxDashBoardController.sessionCurrent!,
      mailboxDashBoardController.accountId.value!,
    ).last;
    return getAllIdentities.fold(
      (failure) => null,
      (success) {
        if (success is GetAllIdentitiesSuccess) {
          return success.identities?.firstOrNull;
        }
        return null;
      },
    );
  }
}