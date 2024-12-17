import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

abstract class BaseScenario {
  final PatrolIntegrationTester $;

  const BaseScenario(this.$);

  Future<void> execute();

  Future<void> expectViewVisible(PatrolFinder patrolFinder) async {
    await $.waitUntilVisible(patrolFinder);
    expect(patrolFinder, findsWidgets);
  }

  Future<void> expectViewInVisible(PatrolFinder patrolFinder) async {
    expect(patrolFinder, findsNothing);
  }
}