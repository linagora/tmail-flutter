import 'package:patrol/patrol.dart';

abstract class CoreRobot {
  final PatrolIntegrationTester $;

  CoreRobot(this.$);

  dynamic ignoreException() => $.tester.takeException();

  MobileAutomator get native => $.platformAutomator.mobile;
}