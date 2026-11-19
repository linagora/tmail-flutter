import 'package:get/get.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

import '../../base/core_robot.dart';
import '../../models/provisioning_email.dart';
import '../../utils/jmap/jmap_email_provisioner.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_mailbox_ready.dart' as wait_for_mailbox_ready;

abstract class AbstractCommonRobot extends CoreRobot {
  AbstractCommonRobot(super.$);

  Future<void> waitForMailboxReady({
    Duration timeout = TestTimeouts.long,
  }) =>
      wait_for_mailbox_ready.waitForMailboxReady(timeout: timeout);

  Future<void> provisionEmail(
    List<ProvisioningEmail> provisioningEmails, {
    bool refreshEmailView = true,
    bool requestReadReceipt = true,
    Role? folderLocationRole,
  }) async {
    await JmapEmailProvisioner().send(
      provisioningEmails,
      requestReadReceipt: requestReadReceipt,
      folderLocationRole: folderLocationRole,
    );

    // Web e2e browser storage can retain mailbox data from a preceding test.
    // A normal refresh may return that cache while the server-side provisioning
    // change is still being reconciled, so force a fresh query on web only.
    if (refreshEmailView) {
      await waitForMailboxReady();
      await Get.find<ThreadController>().refreshAllEmail(
        shouldClearCache: PlatformInfo.isWeb,
      );
    }
  }

  Future<FileInfo> prepareTxtFile(String content);

  Future<void> selectContextMenuItemByName(String name);
}
