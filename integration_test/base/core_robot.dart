import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

abstract class CoreRobot {
  final PatrolIntegrationTester $;

  CoreRobot(this.$);

  Future<void> ensureViewVisible(PatrolFinder patrolFinder) async {
    await $.waitUntilVisible(patrolFinder);
    expect(patrolFinder, findsWidgets);
  }

  dynamic ignoreException() => $.tester.takeException();

  Future<void> grantNotificationPermission() async {
    if (await $.native.isPermissionDialogVisible(timeout: const Duration(seconds: 5))) {
      await $.native.grantPermissionWhenInUse();
    }
  }
}