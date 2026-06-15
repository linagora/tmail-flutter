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
    // Check by subject (contains label name) rather than exact label badge text,
    // since the inbox delivery copy may not carry over custom keywords for badge rendering.
    if (labels.isNotEmpty) {
      final firstLabelName = labels.first.safeDisplayName;
      await waitForCondition(
        () async => $(EmailTileBuilder)
            .which<EmailTileBuilder>(
                (widget) => widget.subjectContains(firstLabelName))
            .evaluate()
            .isNotEmpty,
        timeout: TestTimeouts.long,
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
    // First wait for the search result list container — confirms searchIsRunning=true
    // AND listResultSearch is non-empty before checking individual tiles.
    await $.waitUntilVisible(
      $(#search_email_list_notification_listener),
      timeout: TestTimeouts.medium,
    );

    // The search result list already appeared (#search_email_list_notification_listener
    // is visible). Wait for EmailTileBuilder widgets to be rendered inside it.
    await waitForCondition(
      () async {
        final tiles = $(#search_email_list_notification_listener)
            .$(EmailTileBuilder)
            .evaluate();
        return tiles.length >= emailCount;
      },
      timeout: TestTimeouts.medium,
    );

    final count = $(#search_email_list_notification_listener)
        .$(EmailTileBuilder)
        .evaluate()
        .length;

    expect(count, greaterThanOrEqualTo(emailCount));
  }
}

extension on EmailTileBuilder {
  bool subjectContains(String text) {
    return presentationEmail.subject?.contains(text) == true;
  }
}
