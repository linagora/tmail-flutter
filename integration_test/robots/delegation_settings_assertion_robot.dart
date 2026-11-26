import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
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

  @override
  Future<void> expectNoOneHasAccessToMyMailbox() async {
    final addButton = $(const ValueKey(UiKeys.myDelegatesEmptyCard)).$(LinagoraEmptyCard.actionKey);
    await addButton.waitUntilVisible();
    expect($.tester.widget<LinagoraButton>(addButton).onPressed, isNotNull);
  }

  @override
  Future<void> expectMyDelegatesListed(List<String> delegateAddresses) async {
    final list = $(const ValueKey(UiKeys.myDelegatesList));
    for (final address in delegateAddresses) {
      await list.$(address).waitUntilVisible();
    }
    final addButton = $(const ValueKey(UiKeys.myDelegatesAddButton));
    await addButton.waitUntilVisible();
    expect($.tester.widget<LinagoraButton>(addButton).onPressed, isNotNull);
  }
}
