import 'dart:async';
import 'dart:io' hide HttpClient;

import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identity_interactors_bindings.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:uuid/uuid.dart';

import '../models/provisioning_email.dart';
import '../models/provisioning_identity.dart';

mixin ScenarioUtilsMixin {
  Future<void> provisionEmail(
    List<ProvisioningEmail> provisioningEmails, {
    bool refreshEmailView = true,
    bool requestReadReceipt = true,
    Role? folderLocationRole,
  }) async {
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
          toRecipients: {EmailAddress(null, provisioningEmail.toEmail)},
          outboxMailboxId: mailboxDashBoardController.outboxMailbox?.mailboxId,
          sentMailboxId: folderLocationRole != null
            ? mailboxDashBoardController.mapDefaultMailboxIdByRole[folderLocationRole]
            : mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleSent],
          identity: identity,
          attachments: attachments,
          hasRequestReadReceipt: requestReadReceipt,
        ),
      ).last;
    }));

    // Refresh view after provisioning emails
    if (refreshEmailView) {
      threadController.refreshAllEmail();
    }

    ComposerBindings().dispose();
  }

  Future<void> simulateUpdateFlagsOfEmailsWithSubjectsFromOutsideCurrentClient({
    required List<String> subjects,
    bool? isRead,
    bool? isStar,
  }) async {
    final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
    final emails = mailboxDashBoardController
      .emailsInCurrentMailbox
      .where((presentationEmail) => subjects.contains(
        presentationEmail.subject
      ))
      .toList();
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    if (session == null || accountId == null) return;

    final requestBuilder = JmapRequestBuilder(
      Get.find<HttpClient>(),
      ProcessingInvocation(),
    );
    final capabilities = <CapabilityIdentifier>{};

    // Mark as read/unread
    if (isRead != null) {
      final markEmailAsReadMethod = SetEmailMethod(accountId)
        ..addUpdates(emails.listEmailIds.generateMapUpdateObjectMarkAsRead(
          isRead ? ReadActions.markAsRead : ReadActions.markAsUnread
        ));
      requestBuilder.invocation(markEmailAsReadMethod);
      capabilities.addAll(markEmailAsReadMethod
        .requiredCapabilities
        .toCapabilitiesSupportTeamMailboxes(session, accountId));
    }
    
    // Mark as star/unstar
    if (isStar != null) {
      final markEmailAsStarMethod = SetEmailMethod(accountId)
        ..addUpdates(emails.listEmailIds.generateMapUpdateObjectMarkAsStar(
          isStar ? MarkStarAction.markStar : MarkStarAction.unMarkStar
        ));
      requestBuilder.invocation(markEmailAsStarMethod);
      capabilities.addAll(markEmailAsStarMethod
        .requiredCapabilities
        .toCapabilitiesSupportTeamMailboxes(session, accountId));
    }
    
    await (requestBuilder..usings(capabilities)).build().execute();
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

      try {
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
      } catch (e) {
        logError('ScenarioUtilsMixin::uploadAttachments(): $e');
        return attachments;
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

  bool isMatchingEmailList(List<EmailAddress> emailList, Set<String> allowedEmails) {
    if (emailList.length != allowedEmails.length) {
      return false;
    }

    final Set<String> emails = emailList.map((e) => e.email).whereType<String>().toSet();

    return emails.length == allowedEmails.length && emails.containsAll(allowedEmails);
  }

  Future<void> provisionIdentities(List<ProvisioningIdentity> provisioningIdentities) async {
    IdentityInteractorsBindings().dependencies();

    final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
    final createNewIdentityInteractor = Get.find<CreateNewIdentityInteractor>();
    final createNewDefaultIdentityInteractor = Get.find<CreateNewDefaultIdentityInteractor>();
    const uuid = Uuid();

    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    final listIdentityRequest = provisioningIdentities
      .map((provisioningIdentity) => CreateNewIdentityRequest(
        Id(uuid.v1()),
        provisioningIdentity.identity,
        isDefaultIdentity: provisioningIdentity.isDefault,
      ));

    for (var identityRequest in listIdentityRequest) {
      if (identityRequest.isDefaultIdentity) {
        await createNewDefaultIdentityInteractor
          .execute(session!, accountId!, identityRequest)
          .last;
      } else {
        await createNewIdentityInteractor
          .execute(session!, accountId!, identityRequest)
          .last;
      }
    }

    IdentityInteractorsBindings().dispose();
  }
}