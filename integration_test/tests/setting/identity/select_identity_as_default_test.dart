import '../../../base/test_base.dart';
import '../../../scenarios/setting/identity/set_identity_as_default_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see identity as default when select identity as default',
    scenarioBuilder: ($) => SetIdentityAsDefaultScenario($),
  );
}