import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

import '../abstract/abstract_thread_viewport_robot.dart';

class WebThreadViewportRobot implements AbstractThreadViewportRobot {
  WebThreadViewportRobot(this.$);

  final PatrolIntegrationTester $;

  // Far more rows than one page of 20 fit, so the list only fills it by
  // loading more on its own.
  static const _tallSize = Size(1920, 3000);

  @override
  Future<void> withTallViewport(Future<void> Function() body) async {
    final view = $.tester.view;
    final previousSize = view.physicalSize / view.devicePixelRatio;
    await $.platformAutomator.web.resizeWindow(size: _tallSize);
    await $.pumpAndSettle();
    try {
      await body();
    } finally {
      await $.platformAutomator.web.resizeWindow(size: previousSize);
      await $.pumpAndSettle();
    }
  }
}
