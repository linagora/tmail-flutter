import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';

import '../mobile/mobile_mailbox_menu_robot.dart';

class WebMailboxMenuRobot extends MobileMailboxMenuRobot {
  WebMailboxMenuRobot(super.$);

  @override
  Future<void> openSetting() async {
    await $(const ValueKey(UiKeys.userAvatar)).tap();
    await $(ValueKey(ProfileSettingActionType.manageAccount.name)).tap();
  }

  @override
  Future<void> openTrashContextMenu(String trashFolderName) async {
    final trashItemFinder = $(MailboxItemWidget).which<MailboxItemWidget>(
      (w) => w.mailboxNode.item.name?.name.toLowerCase() ==
          trashFolderName.toLowerCase(),
    );
    await trashItemFinder.waitUntilExists();

    final gesture = await $.tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo($.tester.getCenter(trashItemFinder));
    await $.pump();

    await $(const ValueKey(UiKeys.mailboxMoreActionButton)).tap();
    await $.pumpAndTrySettle();
  }
}