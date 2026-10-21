import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_tag_item_widget.dart';

import '../base/core_robot.dart';
import '../utils/wait_for_condition.dart';
import 'abstract/abstract_composer_recipient_assertion_robot.dart';

class ComposerRecipientAssertionRobot extends CoreRobot
    implements AbstractComposerRecipientAssertionRobot {
  ComposerRecipientAssertionRobot(super.$);

  PatrolFinder _field(PrefixEmailAddress prefix) => $(RecipientComposerWidget)
      .which<RecipientComposerWidget>((widget) => widget.prefix == prefix);

  @override
  void expectRecipientInputOnOwnLine(PrefixEmailAddress prefix) {
    final inputRect = $.tester.getRect(_field(prefix).$(TextField));
    final lastChipRect = $.tester.getRect(_field(prefix).$(RecipientTagItemWidget).last);
    expect(inputRect.top, greaterThanOrEqualTo(lastChipRect.bottom));
  }

  @override
  void expectRecipientInputFocused(PrefixEmailAddress prefix) {
    final field = $.tester.widget<RecipientComposerWidget>(_field(prefix));
    expect(field.focusNode?.hasFocus, isTrue);
  }

  @override
  Future<void> expectRecipientVisible(PrefixEmailAddress prefix, String email) async {
    final chip = _field(prefix).$(RecipientTagItemWidget).which<RecipientTagItemWidget>(
      (widget) => widget.currentEmailAddress.emailAddress == email,
    );
    await waitForCondition(() => chip.evaluate().isNotEmpty);
  }
}
