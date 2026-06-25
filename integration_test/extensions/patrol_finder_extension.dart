
import 'package:flutter/gestures.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_finders/patrol_finders.dart';

import 'patrol_tester_extension.dart';

extension PatrolFinderExtension on PatrolFinder {

  Future<void> enterTextWithoutTapAction(String text) async =>
    wrapWithPatrolLog(
      action: 'enterText',
      color: AnsiCodes.magenta,
      function: () => tester.enterTextWithoutTapAction(
        this,
        text,
        enablePatrolLog: false,
      ),
    );

  /// Presses the secondary (right) mouse button at the center of this widget, then releases.
  Future<void> rightClick() async => wrapWithPatrolLog(
    action: 'rightClick',
    color: AnsiCodes.magenta,
    function: () async {
      final resolved = await tester.waitUntilVisible(this, enablePatrolLog: false);
      final widgetTester = tester.tester;
      final gesture = await widgetTester.startGesture(widgetTester.getCenter(resolved.first), kind: PointerDeviceKind.mouse, buttons: kSecondaryButton);
      await gesture.up();
      await widgetTester.pump();
    },
  );
}