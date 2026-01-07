import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';
import '../../robots/label_robot.dart';
import '../../robots/thread_robot.dart';

class DisplayViewWithAllEmailWithTagScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const DisplayViewWithAllEmailWithTagScenario(super.$);

  @override
  Future<void> setupPreLogin() async {
    PlatformInfo.isIntegrationTesting = true;
  }

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final threadRobot = ThreadRobot($);
    final labelRobot = LabelRobot($);

    final labels = await provisionLabelsByDisplayNames(
      ['Tag 1', 'Tag 2', 'Tag 3'],
    );
    await $.pumpAndSettle();

    int emailCount = 3;
    for (final label in labels) {
      await provisionEmail(
        buildEmailsForLabel(
          label: label,
          toEmail: emailUser,
          count: emailCount,
        ),
        requestReadReceipt: false,
      );
    }
    await $.pumpAndSettle(duration: const Duration(seconds: 2));


    for (final label in labels) {
      await threadRobot.openMailbox();
      await _expectLabelListViewVisible();

      await labelRobot.openLabelByName(label.safeDisplayName);
      await _expectEmailListDisplayedCorrectByTag(
        label: label,
        emailCount: emailCount,
      );

      await $.pumpAndSettle(duration: const Duration(seconds: 1));
    }
  }

  Future<void> _expectLabelListViewVisible() =>
      expectViewVisible($(LabelListView));

  Future<void> _expectEmailListDisplayedCorrectByTag({
    required Label label,
    required int emailCount,
  }) async {
    final tagDisplayName = label.safeDisplayName;

    final listEmailTileWithTag = $.tester.widgetList<EmailTileBuilder>(
      $(EmailTileBuilder).which<EmailTileBuilder>((widget) =>
          widget.presentationEmail.subject?.contains(tagDisplayName) == true),
    );

    expect(listEmailTileWithTag.length, greaterThanOrEqualTo(emailCount));
  }

  @override
  Future<void> disposeAfterTest() async {
    PlatformInfo.isIntegrationTesting = false;
  }
}
