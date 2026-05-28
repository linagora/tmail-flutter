import 'package:flutter/material.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';

import '../abstract/abstract_thread_robot.dart';
import '../thread_robot.dart';

class WebThreadRobot extends ThreadRobot implements AbstractThreadRobot {
  WebThreadRobot(super.$);

  static const Duration _emailOpenPumpDuration = Duration(seconds: 2);

  @override
  Future<void> expectAppGridVisible() async {
    await $(const ValueKey(UiKeys.toggleAppGridButton)).waitUntilVisible();
  }

  @override
  Future<void> openAppGrid() async {
    await $(const ValueKey(UiKeys.toggleAppGridButton)).tap();
  }

  @override
  Future<void> openEmailWithSubject(String subject) async {
    final email = $(EmailTileBuilder).which<EmailTileBuilder>(
      (view) =>
          view.presentationEmail.subject != null &&
          view.presentationEmail.subject == subject,
    );
    await _openEmailTile(email);
  }

  @override
  Future<void> openEmailWithLabel(String labelDisplayName) async {
    final email = $(EmailTileBuilder).which<EmailTileBuilder>(
      (view) =>
          view.labels
              ?.any((label) => label.safeDisplayName == labelDisplayName) ==
          true,
    );
    await _openEmailTile(email);
  }

  @override
  Future<void> tapOnSearchField() async {
    await $(SearchInputFormWidget).$(TextField).tap();
  }

  Future<void> _openEmailTile(PatrolFinder emailFinder) async {
    await $.waitUntilVisible(emailFinder);
    await emailFinder.tap();
    await $.pump(_emailOpenPumpDuration);
  }
}
