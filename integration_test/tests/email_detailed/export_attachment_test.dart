import '../../base/test_base.dart';
import '../../scenarios/email_detailed/export_attachment_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should auto preview attachment when export attachment successfully',
    scenarioBuilder: ($) => ExportAttachmentScenario($),
  );
}