import 'package:flutter/material.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../composer_recipient_robot.dart';

class WebComposerRecipientRobot extends ComposerRecipientRobot {
  WebComposerRecipientRobot(super.$);

  @override
  Future<void> openCcField() async {
    // Web: a wide composer shows Cc as an inline button next to To instead
    // of the expand chevron.
    await $(Key('prefix_${PrefixEmailAddress.to.name}${UiKeys.recipientCcButtonSuffix}')).tap();
  }
}
