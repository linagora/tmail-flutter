import 'dart:async';
import 'dart:convert';
import 'dart:io' hide HttpClient;

import 'package:core/utils/platform_info.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/set/set_mailbox_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/set/set_mailbox_response.dart';
import 'package:model/model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/identity_interactors_bindings.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:uuid/uuid.dart';

import '../extensions/patrol_file_extensions.dart';
import '../factories/robot_factory.dart';
import '../models/provisioning_email.dart';
import '../models/provisioning_identity.dart';
import '../resources/test_images.dart';
import '../utils/wait_for_mailbox_ready.dart';

mixin ScenarioUtilsMixin {
  RobotFactory get robots;

  @Deprecated('Provision email from CommonRobot instead.')
  Future<void> provisionEmail(
    List<ProvisioningEmail> provisioningEmails, {
    bool refreshEmailView = true,
    bool requestReadReceipt = true,
    Role? folderLocationRole,
  }) async {
    final emails = <ProvisioningEmail>[];
    for (final email in provisioningEmails) {
      emails.add(ProvisioningEmail(
        toEmail: email.toEmail,
        subject: email.subject,
        content: email.content,
        fileInfos: [
          ...email.fileInfos,
          for (final path in email.attachmentPaths) await File(path).toFileInfo(),
        ],
        labels: email.labels,
      ));
    }
    await robots.commonRobot().provisionEmail(
      emails,
      refreshEmailView: refreshEmailView,
      requestReadReceipt: requestReadReceipt,
      folderLocationRole: folderLocationRole,
    );
  }

  Future<void> simulateUpdateFlagsOfEmailsWithSubjectsFromOutsideCurrentClient({
    required List<String> subjects,
    bool? isRead,
    bool? isStar,
  }) async {
    final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
    final emails = mailboxDashBoardController.emailsInCurrentMailbox
        .where(
            (presentationEmail) => subjects.contains(presentationEmail.subject))
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
            isRead ? ReadActions.markAsRead : ReadActions.markAsUnread));
      requestBuilder.invocation(markEmailAsReadMethod);
      capabilities.addAll(markEmailAsReadMethod.requiredCapabilities
          .toCapabilitiesSupportTeamMailboxes(session, accountId));
    }

    // Mark as star/unstar
    if (isStar != null) {
      final markEmailAsStarMethod = SetEmailMethod(accountId)
        ..addUpdates(emails.listEmailIds.generateMapUpdateObjectMarkAsStar(
            isStar ? MarkStarAction.markStar : MarkStarAction.unMarkStar));
      requestBuilder.invocation(markEmailAsStarMethod);
      capabilities.addAll(markEmailAsStarMethod.requiredCapabilities
          .toCapabilitiesSupportTeamMailboxes(session, accountId));
    }

    await (requestBuilder..usings(capabilities)).build().execute();
  }

  Future<File> preparingTxtFile(String content) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/test.txt');
    return file.writeAsString(content);
  }

  Future<File> preparingPngWithName(String pngName) async {
    final bytes = base64Decode(TestImages.base64);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$pngName.png');
    return file.writeAsBytes(bytes);
  }

  Future<File> generateImageFromBase64({
    required String fileName,
    required String base64Data,
  }) async {
    final bytes = base64Decode(base64Data);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    return file.writeAsBytes(bytes);
  }

  bool isMatchingEmailList(
      List<EmailAddress> emailList, Set<String> allowedEmails) {
    if (emailList.length != allowedEmails.length) {
      return false;
    }

    final Set<String> emails =
        emailList.map((e) => e.email).whereType<String>().toSet();

    return emails.length == allowedEmails.length &&
        emails.containsAll(allowedEmails);
  }

  Future<void> provisionIdentities(
      List<ProvisioningIdentity> provisioningIdentities) async {
    IdentityInteractorsBindings().dependencies();

    await waitForMailboxReady();

    final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
    final createNewIdentityInteractor = Get.find<CreateNewIdentityInteractor>();
    final createNewDefaultIdentityInteractor =
        Get.find<CreateNewDefaultIdentityInteractor>();
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

  Future<void> provisionTrashSubfolder(String subfolderName) async {
    await waitForMailboxReady();
    final dashboardController = Get.find<MailboxDashBoardController>();
    final session = dashboardController.sessionCurrent
        ?? (throw StateError('provisionTrashSubfolder: session is null'));
    final accountId = dashboardController.accountId.value
        ?? (throw StateError('provisionTrashSubfolder: accountId is null'));
    final trashMailboxId =
        dashboardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleTrash]
        ?? (throw StateError('provisionTrashSubfolder: trashMailboxId is null'));

    await _jmapCreateSubfolder(session, accountId, trashMailboxId, subfolderName);
  }

  Future<void> _jmapCreateSubfolder(
    Session session,
    AccountId accountId,
    MailboxId parentId,
    String name,
  ) async {
    final requestBuilder = JmapRequestBuilder(
      Get.find<HttpClient>(),
      ProcessingInvocation(),
    );
    final setMailboxMethod = SetMailboxMethod(accountId)
      ..addCreate(
        Id(const Uuid().v1()),
        Mailbox(
          name: MailboxName(name),
          parentId: parentId,
          isSubscribed: IsSubscribed(true),
        ),
      );
    final invocation = requestBuilder.invocation(setMailboxMethod);
    final response = await (requestBuilder
          ..usings(setMailboxMethod.requiredCapabilities
              .toCapabilitiesSupportTeamMailboxes(session, accountId)))
        .build()
        .execute();
    final created = response
        .parse<SetMailboxResponse>(invocation.methodCallId, SetMailboxResponse.deserialize)
        ?.created;
    if (created == null || created.isEmpty) {
      throw StateError('provisionTrashSubfolder: mailbox creation failed for "$name"');
    }
  }

  Future<void> mobileBack(PatrolIntegrationTester $) async {
    if (PlatformInfo.isIOS) {
      await $.platformAutomator.ios.swipeBack();
    } else if (PlatformInfo.isAndroid) {
      await $.platformAutomator.android.pressBack();
    } else {
      throw UnsupportedError('mobileBack() is only supported on Android/iOS');
    }
  }
}
