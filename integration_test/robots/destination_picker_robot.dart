import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_view.dart';
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

  /// Finds the folders inside team mailboxes, below their roots.
  PatrolFinder teamMailboxFolders() => $(MailboxItemWidget)
      .which<MailboxItemWidget>(
        (item) => item.mailboxNode.item.isChildOfTeamMailboxes,
      );

  Future<void> scrollToFolder(PatrolFinder finder) => $.scrollUntilVisible(
        finder: finder,
        view: $(DestinationPickerView).$(Scrollable).first,
      );

  /// Picks the first team mailbox folder and returns its displayed name.
  Future<String> selectFirstTeamMailboxFolder() async {
    final folderName = teamMailboxFolders()
        .first
        .$(LabelMailboxItemWidget)
        .$(TextOverflowBuilder)
        .first;
    await scrollToFolder(folderName);
    final displayedName =
        folderName.evaluate().single.widget as TextOverflowBuilder;
    await folderName.tap();
    return displayedName.data;
  }
}
