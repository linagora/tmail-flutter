import 'package:core/presentation/views/search/search_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/web_tablet_body_email_item_widget.dart';

import '../../utils/wait_for_condition.dart';
import '../search_viewport_robot.dart';

class WebSearchViewportRobot extends SearchViewportRobot {
  WebSearchViewportRobot(super.$);

  @override
  Future<void> resizeToMobileViewport() async {
    await $.platformAutomator.web.resizeWindow(
      size: const Size(390, 844),
    );
    await waitForCondition(
      () async => $(SearchBarView).evaluate().isNotEmpty,
    );
  }

  @override
  Future<void> resizeToTabletViewport() async {
    await $.platformAutomator.web.resizeWindow(
      size: const Size(768, 1024),
    );
    await waitForCondition(
      () async => $(WebTabletBodyEmailItemWidget).evaluate().isNotEmpty,
    );
  }
}
