import 'package:flutter/gestures.dart';
import 'package:patrol/patrol.dart';

/// Hovers [target] with a mouse pointer, then taps [action], which only shows
/// on hover: web has no long-press gesture to open a sidebar item's menu.
Future<void> webHoverThenTap(
  PatrolIntegrationTester $,
  PatrolFinder target,
  PatrolFinder action,
) async {
  final gesture = await $.tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  try {
    await gesture.moveTo($.tester.getCenter(target));
    await $.pump();

    await action.tap();
    await $.pumpAndTrySettle();
  } finally {
    await gesture.removePointer();
  }
}
