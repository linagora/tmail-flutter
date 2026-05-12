import 'package:flutter/foundation.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';

import '../mobile/mobile_thread_robot.dart';

class WebThreadRobot extends MobileThreadRobot {
  WebThreadRobot(super.$);

  @override
  Future<void> expectAppGridVisible() async {
    await $(const ValueKey(UiKeys.toggleAppGridButton)).waitUntilVisible();
  }

  @override
  Future<void> openEmailWithSubject(String subject) async {
    final email = $(EmailTileBuilder)
        .which<EmailTileBuilder>((view) => view.presentationEmail.subject == subject);
    await $.waitUntilVisible(email);
    await email.tap();
    await $.pump(const Duration(seconds: 2));
  }

  @override
  Future<void> openEmailWithLabel(String labelDisplayName) async {
    final email = $(EmailTileBuilder).which<EmailTileBuilder>(
      (view) =>
          view.labels
              ?.any((label) => label.safeDisplayName == labelDisplayName) ==
          true,
    );
    await $.waitUntilVisible(email);
    await email.tap();
    await $.pump(const Duration(seconds: 2));
  }
}
