import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter/material.dart';

import '../base/core_robot.dart';
import '../extensions/patrol_finder_extension.dart';

class IdentityCreatorRobot extends CoreRobot {
  IdentityCreatorRobot(super.$);

  Future<void> enterName(String name) async {
    final finder = $(TextFieldBuilder).$(TextField);
    final isTextFieldFocused = finder
        .which<TextField>((view) => view.focusNode?.hasFocus ?? false)
        .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterTextWithoutTapAction(name);
  }

  Future<void> tapSaveIdentityButton() async {
    await $.scrollUntilVisible(finder: $(#save_identity_button));
    await $(#save_identity_button).tap();
  }
}
