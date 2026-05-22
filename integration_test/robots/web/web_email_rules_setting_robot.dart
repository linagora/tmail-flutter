import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../abstract/abstract_email_rules_setting_robot.dart';

class WebEmailRulesSettingRobot extends AbstractEmailRulesSettingRobot {
  WebEmailRulesSettingRobot(super.$);

  @override
  Future<void> expectRuleVisible(String ruleName) async {
    await $.waitUntilVisible($(find.text(ruleName)));
  }

  @override
  Future<void> tapEditRule(String ruleName, String editRuleLabel) async {
    await $(ValueKey('${UiKeys.editEmailRuleButton}_$ruleName')).tap();
  }
}
