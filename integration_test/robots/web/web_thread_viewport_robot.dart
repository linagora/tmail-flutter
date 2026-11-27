import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../abstract/abstract_thread_viewport_robot.dart';

class WebThreadViewportRobot implements AbstractThreadViewportRobot {
  WebThreadViewportRobot(this.$);

  final PatrolIntegrationTester $;

  // Far more rows than one page of 20 fit, so the list only fills it by
  // loading more on its own.
  static const _tallSize = Size(1920, 3000);

  // Below the desktop breakpoint, so the thread shows its compact app bar.
  static const _compactSize = Size(900, 1000);

  @override
  Future<void> withTallViewport(ViewportBody body) =>
      _withWindowSize(_tallSize, body);

  @override
  Future<void> withCompactViewport(ViewportBody body) =>
      _withWindowSize(_compactSize, () async {
        // The desktop Workplace header chip shares its key with the compact one, so wait for the compact app bar first.
        await $(const ValueKey(UiKeys.mobileMailboxMenuButton)).waitUntilVisible();
        await body();
      });

  Future<void> _withWindowSize(
    Size size,
    ViewportBody body,
  ) async {
    final view = $.tester.view;
    final previousSize = view.physicalSize / view.devicePixelRatio;
    await $.platformAutomator.web.resizeWindow(size: size);
    await $.pumpAndSettle();
    try {
      await body();
    } finally {
      await $.platformAutomator.web.resizeWindow(size: previousSize);
      await $.pumpAndSettle();
    }
  }
}
