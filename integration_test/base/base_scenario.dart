import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../utils/test_timer.dart';

abstract class BaseScenario {
  final PatrolIntegrationTester $;

  const BaseScenario(this.$);

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

  /// Wrap an individual test step with timing.
  /// Recorded under 'steps' in the TIMING_REPORT JSON.
  Future<T> timedStep<T>(String name, Future<T> Function() action) {
    return TestTimer().timedStep(name, action);
  }
}
