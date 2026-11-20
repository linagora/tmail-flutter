import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/set/set_mailbox_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/set/set_mailbox_response.dart';
import 'package:model/model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patrol/patrol.dart';
import 'package:uuid/uuid.dart';

import '../extensions/patrol_file_extensions.dart';
import '../factories/robot_factory.dart';
import '../models/provisioning_email.dart';
import '../models/provisioning_identity.dart';
import '../resources/test_images.dart';
import '../utils/jmap/jmap_email_flags_updater.dart';
import '../utils/jmap/jmap_identity_provisioner.dart';
import '../utils/jmap/jmap_test_client.dart';

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
  }) =>
      JmapEmailFlagsUpdater().update(
        subjects: subjects,
        isRead: isRead,
        isStar: isStar,
      );

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
    List<ProvisioningIdentity> provisioningIdentities,
  ) =>
      JmapIdentityProvisioner().create(provisioningIdentities);

  Future<void> provisionTrashSubfolder(String subfolderName) async {
    final client = await JmapTestClient.current();
    final trashMailboxId = await client.mailboxIdByRole(PresentationMailbox.roleTrash);
    final response = await client.execute(
      SetMailboxMethod(client.accountId)
        ..addCreate(
          Id(const Uuid().v1()),
          Mailbox(
            name: MailboxName(subfolderName),
            parentId: trashMailboxId,
            isSubscribed: IsSubscribed(true),
          ),
        ),
      SetMailboxResponse.deserialize,
    );
    if (response.created?.isNotEmpty != true) {
      throw StateError(
        'provisionTrashSubfolder: mailbox creation failed for "$subfolderName"',
      );
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
