import 'package:core/presentation/views/search/search_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/widget/compose_floating_button.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';

import '../base/core_robot.dart';

class ThreadRobot extends CoreRobot {
  ThreadRobot(super.$);

  Future<void> openComposer() async {
    await $(ComposeFloatingButton).$(InkWell).tap();
  }

  Future<void> openSearchView() async {
    await $(SearchBarView).$(InkWell).tap();
  }

  Future<void> tapOnSearchField() async {
    await $(ThreadView).$(SearchBarView).tap();
  }

  Future<void> openEmailWithSubject(String subject) async {
    await $(find.byType(EmailTileBuilder))
      .which<EmailTileBuilder>((view) => view.presentationEmail.subject == subject)
      .first
      .tap();
    await $.pump(const Duration(seconds: 2));
  }

  Future<void> openMailbox() async {
    await $(#mobile_mailbox_menu_button).tap();
  }

  Future<void> longPressEmailWithSubject(String subject) async {
    await $(subject).longPress();
  }

  Future<void> selectToggleRead() async {
    await $(#mark_as_read_selected_email_button).tap();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
  }

  Future<void> selectToggleStar() async {
    await $(#mark_as_star_selected_email_button).tap();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
  }

  Future<void> selectToggleSpam() async {
    await $(#move_selected_email_to_spam_button).tap();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
  }
}