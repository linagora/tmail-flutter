import 'package:core/presentation/views/search/search_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/compose_floating_button.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';

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
}