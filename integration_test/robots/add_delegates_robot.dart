import 'package:flutter/material.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../base/core_robot.dart';
import '../extensions/patrol_finder_extension.dart';
import 'abstract/abstract_add_delegates_robot.dart';

class AddDelegatesRobot extends CoreRobot implements AbstractAddDelegatesRobot {
  AddDelegatesRobot(super.$);

  @override
  Future<void> openFromEmptyCard() async {
    await $(const ValueKey(UiKeys.myDelegatesEmptyCard)).$(LinagoraEmptyCard.actionKey).tap();
  }

  @override
  Future<void> enterDelegateAddress(String address) async {
    await $(const ValueKey(UiKeys.addDelegatesAddressField)).$(TextField).enterTextWithoutTapAction(address);
    // Profile web builds keep the mock text input registered, which swallows the browser's Enter.
    if ($.tester.testTextInput.isRegistered) {
      await $.tester.testTextInput.receiveAction(TextInputAction.done);
    } else {
      await $.platformAutomator.web.pressKeyCombo(keys: ['Enter']);
    }
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> tapNext() async {
    await $(const ValueKey(UiKeys.addDelegatesNextButton)).tap();
  }

  @override
  Future<void> tapSubmit() async {
    await $(const ValueKey(UiKeys.addDelegatesSubmitButton)).tap();
  }
}
