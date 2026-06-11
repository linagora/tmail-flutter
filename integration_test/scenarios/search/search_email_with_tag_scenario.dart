import 'package:flutter_test/flutter_test.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';

class SearchEmailWithTagScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const SearchEmailWithTagScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final commonRobot = robots.commonRobot();
    final searchRobot = robots.searchRobot();

    // Labels are created directly through the dashboard controller, which only
    // becomes available after the seeded-credentials login settles. Wait for it
    // before provisioning, otherwise the labels come back empty (no accountId).
    await commonRobot.waitForMailboxReady();

    final labels = await provisionLabelsByDisplayNames(
      ['Search Tag 1', 'Search Tag 2', 'Search Tag 3'],
    );
    await $.pumpAndSettle();

    int emailCount = 3;
    for (final label in labels) {
      await commonRobot.provisionEmail(
        buildEmailsForLabel(
          label: label,
          toEmail: emailUser,
          count: emailCount,
        ),
        requestReadReceipt: false,
      );
    }

    // Wait for provisioned emails to appear in the inbox.
    // waitForCondition uses Future.delayed between retries, which yields to the
    // browser event loop on web so JMAP XHR callbacks can fire.
    if (labels.isNotEmpty) {
      await waitForCondition(
        () async => $(labels.first.safeDisplayName).evaluate().isNotEmpty,
        timeout: TestTimeouts.medium,
      );
    }

    await searchRobot.tapOnSearchField();

    for (final label in labels) {
      final labelDisplayName = label.safeDisplayName;

      await searchRobot.openLabelListModal();
      await _expectLabelListContextMenuVisible();

      await commonRobot.selectContextMenuItemByName(labelDisplayName);
      await _expectEmailListDisplayedCorrectByTag(
        tagDisplayName: labelDisplayName,
        emailCount: emailCount,
      );

      await $.pumpAndSettle(duration: const Duration(seconds: 1));
    }
  }

  Future<void> _expectLabelListContextMenuVisible() async {
    // Mobile: bottom sheet identified by #label_list_bottom_sheet_context_menu.
    // Web: showMenu popup has no container key — identified by PopupMenuItemActionWidget.
    await waitForCondition(
      () async =>
        $(#label_list_bottom_sheet_context_menu).evaluate().isNotEmpty ||
        $(PopupMenuItemActionWidget).evaluate().isNotEmpty,
      timeout: TestTimeouts.short,
    );
  }

  Future<void> _expectEmailListDisplayedCorrectByTag({
    required String tagDisplayName,
    required int emailCount,
  }) async {
    // waitForCondition yields to the browser event loop between retries (via
    // Future.delayed), allowing JMAP XHR callbacks to fire on web.
    await waitForCondition(
      () async {
        final count = $(EmailTileBuilder).which<EmailTileBuilder>((widget) =>
            widget.subjectContains(tagDisplayName)).evaluate().length;
        return count >= emailCount;
      },
      timeout: TestTimeouts.medium,
    );

    final listEmailTileWithTag = $(EmailTileBuilder).which<EmailTileBuilder>((widget) =>
        widget.subjectContains(tagDisplayName)).allCandidates;

    expect(listEmailTileWithTag.length, greaterThanOrEqualTo(emailCount));
  }
}

extension on EmailTileBuilder {
  bool subjectContains(String text) {
    return presentationEmail.subject?.contains(text) == true;
  }
}
