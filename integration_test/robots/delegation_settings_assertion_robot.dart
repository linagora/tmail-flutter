import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_delegation_settings_assertion_robot.dart';

class DelegationSettingsAssertionRobot extends CoreRobot
    implements AbstractDelegationSettingsAssertionRobot {
  DelegationSettingsAssertionRobot(super.$);

  @override
  Future<void> expectDelegatedToMeListed(String ownerAddress) async {
    await $(const ValueKey(UiKeys.delegatedToMeList)).$(ownerAddress).waitUntilVisible();
  }

  @override
  Future<void> expectNothingDelegatedToMe() async {
    await $(const ValueKey(UiKeys.delegatedToMeEmptyCard)).waitUntilVisible();
  }
}
