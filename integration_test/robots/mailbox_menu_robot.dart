import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/label_mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_view.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

import '../base/core_robot.dart';
import '../exceptions/mailbox/null_inbox_unread_count_exception.dart';
import '../exceptions/mailbox/null_quota_exception.dart';
import 'abstract/abstract_mailbox_assertion_robot.dart';
import 'abstract/abstract_mailbox_empty_trash_robot.dart';
import 'abstract/abstract_mailbox_folder_robot.dart';
import 'abstract/abstract_mailbox_menu_robot.dart';
import 'abstract/abstract_mailbox_navigation_robot.dart';
import 'mailbox_assertion_robot.dart';
import 'mailbox_empty_trash_robot.dart';
import 'mailbox_folder_robot.dart';
import 'mailbox_navigation_robot.dart';

class MailboxMenuRobot extends CoreRobot implements AbstractMailboxMenuRobot {
  @override
  final AbstractMailboxNavigationRobot navigation;

  @override
  final AbstractMailboxFolderRobot folder;

  @override
  final AbstractMailboxEmptyTrashRobot emptyTrash;

  @override
  final AbstractMailboxAssertionRobot assertion;

  MailboxMenuRobot(
    PatrolIntegrationTester $, {
    AbstractMailboxNavigationRobot? navigationRobot,
  })  : navigation = navigationRobot ?? MailboxNavigationRobot($),
        folder = MailboxFolderRobot($),
        emptyTrash = MailboxEmptyTrashRobot($),
        assertion = MailboxAssertionRobot($),
        super($);

  final _l10n = AppLocalizations();

  //// Finds a mailbox item containing the given display name text.
  @override
  PatrolFinder mailboxItemByName(String name) =>
      $(MailboxItemWidget).$(LabelMailboxItemWidget).$(name);

  /// Finds a mailbox item whose name exactly matches the given value.
  @override
  PatrolFinder mailboxItemByExactName(String name) =>
      $(MailboxItemWidget).which<MailboxItemWidget>((w) => w.mailboxNode.item.name?.name.toLowerCase() == name.toLowerCase());

  @override
  Future<void> openSetting() async {
    await $(const ValueKey(UiKeys.userAvatar)).tap();
  }

  Future<void> openMailboxSearch() async {
    await $(TMailButtonWidget)
      .which<TMailButtonWidget>((widget) {
        return widget.icon == ImagePaths().icSearchBar;
      })
      .tap();
  }

  Future<void> searchMailbox(String query) async {
    await $(SearchMailboxView).$(TextFieldBuilder).enterText(query);
    await $.pumpAndSettle();
  }

  Future<void> closeMenu() async {
    await native.swipe(from: const Offset(0.9, 0.5), to: const Offset(0, 0.5));
  }

  int getCurrentInboxCount() {
    final inboxCount = Get.find<MailboxDashBoardController>()
      .selectedMailbox
      .value
      ?.unreadEmails
      ?.value
      .value
      .toInt();

    if (inboxCount == null) {
      throw const NullInboxUnreadCountException();
    }

    return inboxCount;
  }

  Future<void> tapSignOut() async {
    await $.scrollUntilVisible(finder: $(_l10n.sign_out));
    await $(_l10n.sign_out).tap();
  }

  Future<void> confirmSignOut() async {
    await $(_l10n.yesLogout).tap();
  }

  int getUsedQuota() {
    final usedQuota =
        getBinding<MailboxDashBoardController>()?.octetsQuota.value?.used?.value.toInt();
    if (usedQuota == null) throw NullQuotaException();

    return usedQuota;
  }

  Future<void> refreshQuota() async {
    getBinding<QuotasController>()?.reloadQuota();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
  }

  Future<void> tapRecoverDeletedMessages() async {
    await $(_l10n.recoverDeletedMessages).tap();
  }

  Future<void> tapConfirmRecoverDeletedMessages() async {
    if (await native.isPermissionDialogVisible(timeout: const Duration(seconds: 2))) {
      await native.grantPermissionWhenInUse();
    }
    await $(_l10n.restore).tap();
    await $.pumpAndSettle();
  }

  Future<void> tapMarkAsRead() async {
    await $(_l10n.mark_as_read).tap();
    await $.pumpAndSettle();
  }

  @override
  Future<void> pullToRefresh() async {
    await $.platformAutomator.mobile.pullToRefresh();
  }
}
