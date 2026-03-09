import 'package:flutter_test/flutter_test.dart';
import 'package:labels/labels.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';
import '../../robots/label_robot.dart';
import '../../robots/thread_robot.dart';

class DisplayFolderInfoWhenOpenMailFromTagScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const DisplayFolderInfoWhenOpenMailFromTagScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final threadRobot = ThreadRobot($);
    final labelRobot = LabelRobot($);

    final labels = await provisionLabelsByDisplayNames(
      ['Tag 1'],
    );
    await $.pumpAndSettle();
    final newLabel = labels.first;

    await provisionEmail(
      buildEmailsForLabel(
        label: newLabel,
        toEmail: emailUser,
        count: 1,
      ),
      requestReadReceipt: false,
      folderLocationRole: PresentationMailbox.roleTrash,
    );
    await provisionEmail(
      buildEmailsForLabel(
        label: newLabel,
        toEmail: emailUser,
        count: 1,
      ),
      requestReadReceipt: false,
      folderLocationRole: PresentationMailbox.roleTrash,
    );
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.openMailbox();
    await _expectLabelListViewVisible();

    await labelRobot.openLabelByName(newLabel.safeDisplayName);
    await _expectFolderInfoDisplayed();
  }

  Future<void> _expectLabelListViewVisible() =>
      expectViewVisible($(LabelListView));

  Future<void> _expectFolderInfoDisplayed() async {
    await expectViewVisible($(AppLocalizations().trashMailboxDisplayName));
  }
}
