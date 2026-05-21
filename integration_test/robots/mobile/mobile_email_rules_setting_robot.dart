import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../abstract/abstract_email_rules_setting_robot.dart';

class MobileEmailRulesSettingRobot extends AbstractEmailRulesSettingRobot {
  MobileEmailRulesSettingRobot(super.$);

  @override
  Future<void> expectRuleVisible(String ruleName) async {
    await $.waitUntilVisible($(find.text(ruleName)));
  }

  @override
  Future<void> tapEditRule(String ruleName, String editRuleLabel) async {
    await $(ValueKey('${UiKeys.moreEmailRuleButton}_$ruleName')).tap();
    await $.pumpAndTrySettle();
    await $(find.text(editRuleLabel)).tap();
  }
}
