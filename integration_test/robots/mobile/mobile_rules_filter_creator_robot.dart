import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_view.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';

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
    await _hideKeyboard();
    await $(find.text(selectActionHint)).tap();
    await $.pumpAndTrySettle();
    await $(find.text(actionName)).tap();
  }

  // The creator autofocuses the name field; patrol_finders 3.2.0 enterText leaves its mock text input registered, which swallows every hide
  Future<void> _hideKeyboard() async {
    $.tester.testTextInput.unregister();
    FocusManager.instance.primaryFocus?.unfocus();
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    final view = $.tester.view;
    for (var i = 0; i < 20 && view.viewInsets.bottom > 0; i++) {
      await $.tester.pump(const Duration(milliseconds: 250));
    }
    if (view.viewInsets.bottom > 0) {
      throw StateError('Keyboard still open after 5 s (inset ${view.viewInsets.bottom})');
    }
  }

  @override
  Future<void> tapAddActionButton() async {
    const addActionButtonKey = ValueKey(UiKeys.addActionButton);
    await $(addActionButtonKey).scrollTo();
    await $(addActionButtonKey).tap();
  }

  @override
  Future<void> openMoveMessageFolderPicker() async {
    await $(RuleFilterButtonField<PresentationMailbox>).tap();
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
