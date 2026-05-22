import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_view.dart';

import '../abstract/abstract_rules_filter_creator_robot.dart';

class MobileRulesFilterCreatorRobot extends AbstractRulesFilterCreatorRobot {
  MobileRulesFilterCreatorRobot(super.$);

  @override
  Future<void> expectCreatorViewVisible() =>
      $.waitUntilVisible($(RuleFilterCreatorView));

  @override
  Future<void> enterRuleName(String name) async {
    await $(RuleFilterCreatorView).$(TextField).enterText(name);
  }

  @override
  Future<void> selectEmptyActionSlot(
    String actionName,
    String selectActionHint,
  ) async {
    await $(find.text(selectActionHint)).tap();
    await $.pumpAndTrySettle();
    await $(find.text(actionName)).tap();
  }

  @override
  Future<void> tapAddActionButton() async {
    const addActionButtonKey = ValueKey(UiKeys.addActionButton);
    await $(addActionButtonKey).scrollTo();
    await $(addActionButtonKey).tap();
  }

  @override
  Future<void> tapCreateRuleButton() async {
    await $(const ValueKey(UiKeys.createRuleButton)).tap();
  }

  @override
  Future<void> expectWarningTextVisible(String warningText) async {
    await $.waitUntilVisible($(warningText));
  }

  @override
  Future<void> confirmWarningDialog(String confirmLabel) async {
    await $(find.text(confirmLabel)).tap();
  }

  @override
  Future<void> expectCreatorViewClosed() async {
    expect($(RuleFilterCreatorView), findsNothing);
  }
}
