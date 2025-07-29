import '../../base/test_base.dart';
import '../../scenarios/thread_detail/thread_detail_reply_real_time_update_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see reply of thread detail',
    scenarioBuilder: ($) => ThreadDetailReplyRealTimeUpdateScenario($),
  );
}