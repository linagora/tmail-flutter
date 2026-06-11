import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/extensions/list_label_extension.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/upload/file_info.dart';
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
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

import '../../base/core_robot.dart';
import '../../models/provisioning_email.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';

abstract class AbstractCommonRobot extends CoreRobot {
  AbstractCommonRobot(super.$);

  /// Waits until the mailbox dashboard is fully loaded (session, account id and
  /// selected mailbox are available). The app reaches this state only after the
  /// silent (seeded-credentials) login completes, so callers that provision data
  /// directly through controllers must await this before touching them.
  Future<void> waitForMailboxReady({
    Duration timeout = TestTimeouts.long,
  }) async {
    await waitForCondition(
      () => _isMailboxReady(getBinding<MailboxDashBoardController>()),
      timeout: timeout,
    );
  }

  Future<void> provisionEmail(
    List<ProvisioningEmail> provisioningEmails, {
    bool refreshEmailView = true,
    bool requestReadReceipt = true,
    Role? folderLocationRole,
  }) async {
    ComposerBindings().dependencies();

    await waitForMailboxReady();
    final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
    final createNewAndSendEmailInteractor =
        Get.find<CreateNewAndSendEmailInteractor>();
    final threadController = Get.find<ThreadController>();

    final identity = await _getIdentity();

    if (identity == null) return;

    // Provision emails
    await Future.wait(provisioningEmails.map((provisioningEmail) async {
      final attachments =
          await Future.wait(provisioningEmail.fileInfos.map(uploadAttachments));

      // Create and send email
      return await createNewAndSendEmailInteractor
          .execute(
            createEmailRequest: CreateEmailRequest(
              session: mailboxDashBoardController.sessionCurrent!,
              accountId: mailboxDashBoardController.accountId.value!,
              emailActionType: EmailActionType.compose,
              ownEmailAddress: mailboxDashBoardController.ownEmailAddress.value,
              subject: provisioningEmail.subject,
              emailContent: provisioningEmail.content,
              toRecipients: {EmailAddress(null, provisioningEmail.toEmail)},
              outboxMailboxId:
                  mailboxDashBoardController.outboxMailbox?.mailboxId,
              sentMailboxId: folderLocationRole != null
                  ? mailboxDashBoardController
                      .mapDefaultMailboxIdByRole[folderLocationRole]
                  : mailboxDashBoardController
                      .mapDefaultMailboxIdByRole[PresentationMailbox.roleSent],
              identity: identity,
              attachments: attachments,
              hasRequestReadReceipt: requestReadReceipt,
              keywords: provisioningEmail.labels.keywords,
            ),
          )
          .last;
    }));

    // Refresh view after provisioning emails
    if (refreshEmailView) {
      await threadController.refreshAllEmail();
    }

    ComposerBindings().dispose();
  }

  bool _isMailboxReady(MailboxDashBoardController? mailboxDashBoardController) {
    return mailboxDashBoardController != null &&
        mailboxDashBoardController.sessionCurrent != null &&
        mailboxDashBoardController.accountId.value != null &&
        mailboxDashBoardController.selectedMailbox.value != null;
  }

  Future<Identity?> _getIdentity() async {
    final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
    final getAllIdentitiesInteractor = Get.find<GetAllIdentitiesInteractor>();
    final getAllIdentities = await getAllIdentitiesInteractor
        .execute(
          mailboxDashBoardController.sessionCurrent!,
          mailboxDashBoardController.accountId.value!,
        )
        .last;
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

  Future<Attachment> uploadAttachments(FileInfo fileInfo) async {
    final mailboxDashBoardController = Get.find<MailboxDashBoardController>();

    final uploadUri = mailboxDashBoardController.sessionCurrent!.getUploadUri(
      mailboxDashBoardController.accountId.value!,
      jmapUrl: mailboxDashBoardController.dynamicUrlInterceptors.jmapUrl,
    );

    final uploadAttachmentInteractor = Get.find<UploadAttachmentInteractor>();
    final uploadAttachmentState =
        await uploadAttachmentInteractor.execute(fileInfo, uploadUri).last;
    final attachment = await uploadAttachmentState.fold(
      (failure) => null,
      (success) async {
        if (success is UploadAttachmentSuccess) {
          final uploadAttachment =
              await success.uploadAttachment.progressState.last;
          return uploadAttachment.fold(
            (failure) => null,
            (success) => success is SuccessAttachmentUploadState
                ? success.attachment
                : null,
          );
        }
      },
    );
    // If attachment is null, the test will fail anyway,
    // so we can ignore the null check
    return attachment!;
  }

  Future<FileInfo> prepareTxtFile(String content);

  Future<void> selectContextMenuItemByName(String name);
}
