import '../../base/test_base.dart';
import '../../scenarios/download_all_attachments_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see save dialog when download all attachments successfully',
    scenarioBuilder: ($) => DownloadAllAttachmentsScenario($),
  );
}