import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/dashboard_vacation_banner.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_shown_account_offers_assertion_robot.dart';

class WebShownAccountOffersAssertionRobot extends CoreRobot
    implements AbstractShownAccountOffersAssertionRobot {
  WebShownAccountOffersAssertionRobot(super.$);

  Finder get _recoverDeletedMessagesButton =>
      find.byKey(const ValueKey(UiKeys.recoverDeletedMessagesButton));

  @override
  Future<void> expectMyVacationBannerShown() async {
    await waitForCondition(
      () => $(VacationNotificationMessageWidget).evaluate().isNotEmpty,
      reason: 'my vacation banner is shown',
    );
  }

  @override
  Future<void> expectMyVacationBannerHidden() async {
    await $.pumpAndTrySettle();
    // The banner slot is built for a valid vacation, so only the shown-account gate can hide it.
    expect(find.byType(DashboardVacationBanner), findsWidgets);
    expect(find.byType(VacationNotificationMessageWidget), findsNothing);
  }

  @override
  Future<void> expectRecoverDeletedMessagesOffered() async {
    await waitForCondition(
      () => _recoverDeletedMessagesButton.evaluate().isNotEmpty,
      reason: 'Recover deleted messages is offered in Trash',
    );
  }

  @override
  Future<void> expectRecoverDeletedMessagesNotOffered() async {
    // Trash must be open, else the button is absent for being outside Trash.
    await waitForCondition(
      () => Get.find<MailboxDashBoardController>().selectedMailbox.value?.isTrashPersonal == true,
      reason: 'Trash is open',
    );
    await $.pumpAndTrySettle();
    expect(_recoverDeletedMessagesButton, findsNothing);
  }

  @override
  Future<void> expectRecipientMenuWithoutCreateRule() async {
    final l10n = AppLocalizations();
    // The menu must be open, else Create a rule is absent for being closed.
    await $(l10n.editEmail).waitUntilVisible();
    expect(find.text(l10n.createARule), findsNothing);
  }
}
