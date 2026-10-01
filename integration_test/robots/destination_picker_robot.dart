import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/label_mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_destination_picker_assertion_robot.dart';
import 'destination_picker_assertion_robot.dart';

class DestinationPickerRobot extends CoreRobot {
  final AbstractDestinationPickerAssertionRobot assertion;

  DestinationPickerRobot(PatrolIntegrationTester $)
      : assertion = DestinationPickerAssertionRobot($),
        super($);

  /// Finds a folder of the destination picker by its display name.
  PatrolFinder folderByName(String name) => $(MailboxItemWidget)
      .$(LabelMailboxItemWidget)
      .$(find.text(name));

  Future<void> selectFolderByName(String name) async {
    await folderByName(name).tap();
  }
}
