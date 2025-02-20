import '../../base/test_base.dart';
import '../../scenarios/web_socket_update_ui_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see thread view updated per web socket message',
    scenarioBuilder: ($) => WebSocketUpdateUiScenario($),
  );
}