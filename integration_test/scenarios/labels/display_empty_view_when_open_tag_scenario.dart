import 'package:flutter_test/flutter_test.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';
import '../../robots/label_robot.dart';
import '../../robots/thread_robot.dart';

class DisplayEmptyViewWhenOpenTagScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const DisplayEmptyViewWhenOpenTagScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final threadRobot = ThreadRobot($);
    final labelRobot = LabelRobot($);

    final labels = await provisionLabelsByDisplayNames(
      ['Tag with email', 'Tag without email'],
    );
    await $.pumpAndSettle();

    int emailCount = 3;
    final labelWithEmail =
        labels.firstWhere((label) => label.safeDisplayName == 'Tag with email');
    final labelWithoutEmail = labels
        .firstWhere((label) => label.safeDisplayName == 'Tag without email');

    await provisionEmail(
      buildEmailsForLabel(
        label: labelWithEmail,
        toEmail: emailUser,
        count: emailCount,
      ),
      requestReadReceipt: false,
    );
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.openMailbox();
    await _expectLabelListViewVisible();

    await labelRobot.openLabelByName(labelWithEmail.safeDisplayName);
    await _expectEmailListDisplayedCorrectByTag(
      label: labelWithEmail,
      emailCount: emailCount,
    );

    await $.pumpAndSettle(duration: const Duration(seconds: 1));

    await threadRobot.openMailbox();
    await _expectLabelListViewVisible();

    await labelRobot.openLabelByName(labelWithoutEmail.safeDisplayName);
    await _expectEmptyViewVisible();
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

  Future<void> _expectEmptyViewVisible() async {
    await expectViewVisible($(#empty_thread_view));

    await expectViewVisible(
      $(find.text(AppLocalizations().youDoNotHaveAnyEmailTaggedWithThis)),
    );
  }
}
