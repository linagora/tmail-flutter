import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';
import '../../robots/label_list_context_menu_robot.dart';
import '../../robots/search_robot.dart';
import '../../robots/thread_robot.dart';

class SearchEmailWithTagScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const SearchEmailWithTagScenario(super.$);

  @override
  Future<void> setupPreLogin() async {
    PlatformInfo.isIntegrationTesting = true;
  }

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final threadRobot = ThreadRobot($);
    final searchRobot = SearchRobot($);
    final labelListContextMenuRobot = LabelListContextMenuRobot($);

    final labels = await provisionLabelsByDisplayNames(
      ['Search Tag 1', 'Search Tag 2', 'Search Tag 3'],
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

    await threadRobot.openSearchView();
    await _expectSearchViewVisible();

    for (final label in labels) {
      final labelDisplayName = label.safeDisplayName;

      await searchRobot.openLabelListModal();
      await _expectLabelListContextMenuVisible();

      await labelListContextMenuRobot.selectLabelByName(labelDisplayName);
      await _expectEmailListDisplayedCorrectByTag(
        tagDisplayName: labelDisplayName,
        emailCount: emailCount,
      );

      await $.pumpAndSettle(duration: const Duration(seconds: 1));
    }
  }

  Future<void> _expectSearchViewVisible() async {
    await expectViewVisible($(SearchEmailView));
  }

  Future<void> _expectLabelListContextMenuVisible() async {
    await expectViewVisible($(#label_list_bottom_sheet_context_menu));
  }

  Future<void> _expectEmailListDisplayedCorrectByTag({
    required String tagDisplayName,
    required int emailCount,
  }) async {
    // Emails provisioned by buildEmailsForLabel include the tag name in the subject
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
