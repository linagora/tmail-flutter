import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

abstract class BaseScenario {
  final PatrolIntegrationTester $;

  const BaseScenario(this.$);

  /// Runs after app dependencies are initialized but before the app starts.
  ///
  /// Scenarios can use this hook to prepare state that startup reads, without
  /// racing the first frame.
  Future<void> prepare() async {}

  Future<void> execute();

  Future<void> expectViewVisible(
    PatrolFinder patrolFinder, {
    Alignment alignment = Alignment.center,
  }) async {
    await $.waitUntilVisible(patrolFinder, alignment: alignment);
    expect(patrolFinder, findsWidgets);
  }

  Future<void> expectViewInvisible(PatrolFinder patrolFinder) async {
    expect(patrolFinder, findsNothing);
  }
}
