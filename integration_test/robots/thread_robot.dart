import 'package:core/presentation/views/search/search_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/compose_floating_button.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';

import '../base/core_robot.dart';

class ThreadRobot extends CoreRobot {
  ThreadRobot(super.$);

  Future<void> expectThreadViewVisible() => ensureViewVisible($(ThreadView));

  Future<void> openComposer() async {
    await $(ComposeFloatingButton).$(InkWell).tap();
  }

  Future<void> expectComposerViewVisible() => ensureViewVisible($(ComposerView));

  Future<void> tapOnSearchField() async {
    await $(ThreadView).$(SearchBarView).tap();
  }
}