import 'package:flutter_test/flutter_test.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_subject_widget.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';
import '../../robots/email_robot.dart';
import '../../robots/label_robot.dart';
import '../../robots/thread_robot.dart';

class RemoveALabelFromEmailScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const RemoveALabelFromEmailScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    expect(emailUser, isNotEmpty, reason: 'BASIC_AUTH_EMAIL must be set');

    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);
    final labelRobot = LabelRobot($);

    final labels = await provisionLabelsByDisplayNames(
      ['Remove Tag 1'],
    );
    await $.pumpAndSettle();

    final firstLabel = labels.first;
    final labelDisplayName = firstLabel.safeDisplayName;
    await provisionEmail(
      buildEmailsForLabel(
        label: firstLabel,
        toEmail: emailUser,
        count: 1,
      ),
      requestReadReceipt: false,
    );
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.openMailbox();
    await _expectLabelListViewVisible();

    await labelRobot.openLabelByName(labelDisplayName);
    await _expectEmailListDisplayedCorrectByTag(labelDisplayName);

    await threadRobot.openEmailWithLabel(labelDisplayName);
    await _expectLabelDisplayedOnEmailSubject(labelDisplayName);

    await emailRobot.tapRemoveLabelButton(labelDisplayName);
    await _expectRemoveLabelFromEmailSuccessToast(labelDisplayName);
  }

  Future<void> _expectLabelListViewVisible() =>
      expectViewVisible($(LabelListView));

  Future<void> _expectEmailListDisplayedCorrectByTag(
    String labelDisplayName,
  ) async {
    final listEmailTileWithTag = $.tester.widgetList<EmailTileBuilder>(
      $(EmailTileBuilder).which<EmailTileBuilder>((widget) =>
          widget.presentationEmail.subject?.contains(labelDisplayName) == true),
    );

    expect(listEmailTileWithTag.length, greaterThanOrEqualTo(1));
  }

  Future<void> _expectLabelDisplayedOnEmailSubject(
    String labelDisplayName,
  ) async {
    expect(
      $(EmailSubjectWidget)
          .$(LabelWidget)
          .which<LabelWidget>(
              (widget) => widget.label.safeDisplayName == labelDisplayName)
          .visible,
      true,
    );
  }

  Future<void> _expectRemoveLabelFromEmailSuccessToast(
    String labelDisplayName,
  ) async {
    await expectViewVisible(
      $(find.text(AppLocalizations()
          .removeLabelFromEmailSuccessfullyMessage(labelDisplayName))),
    );
  }
}
