import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';

import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/label_mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_view.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

import '../base/core_robot.dart';
import '../exceptions/mailbox/null_inbox_unread_count_exception.dart';
import '../exceptions/mailbox/null_quota_exception.dart';

class MailboxMenuRobot extends CoreRobot {
  MailboxMenuRobot(super.$);

  Future<void> openAppGrid() async {
    await $(#toggle_app_grid_button).tap();
  }

  Future<void> openFolderByName(String name) async {
    final mailboxItem = $(MailboxItemWidget).$(LabelMailboxItemWidget).$(name);
    await $.scrollUntilVisible(finder: mailboxItem);
    await mailboxItem.tap();
  }

  Future<void> openSetting() async {
    await $(#user_avatar).tap();
  }

  Future<void> longPressMailboxWithName(String name) async {
    await $(name).longPress();
    await $.pumpAndSettle();
  }

  Future<void> tapCreateNewSubFolder() async {
    await $(AppLocalizations().newSubfolder).tap();
  }

  Future<void> enterNewFolderName(String name) async {
    await $(MailboxCreatorView)
        .$(TextFieldBuilder)
        .enterText(name);
  }

  Future<void> confirmCreateNewFolder() async {
    await $(MailboxCreatorView)
        .$(AppLocalizations().createFolder)
        .tap();
  }

  Future<void> expandMailboxWithName(String name) async {
    await $(MailboxItemWidget)
        .which<MailboxItemWidget>((widget) {
          return widget.mailboxNode.item.name?.name.toLowerCase() ==
              name.toLowerCase();
        })
        .$(#expand_mailbox_button)
        .tap();
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

  Future<void> tapHideMailbox() async {
    await $(AppLocalizations().hideFolder).tap();
  }

  Future<void> closeMenu() async {
    await $.native.swipe(from: const Offset(0.9, 0.5), to: const Offset(0, 0.5));
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
      throw NullInboxUnreadCountException();
    }

    return inboxCount;
  }

  Future<void> tapSignOut() async {
    await $.scrollUntilVisible(finder: $(AppLocalizations().sign_out));
    await $(AppLocalizations().sign_out).tap();
  }

  Future<void> confirmSignOut() async {
    await $(AppLocalizations().yesLogout).tap();
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
    await $(AppLocalizations().recoverDeletedMessages).tap();
  }

  Future<void> tapConfirmRecoverDeletedMessages() async {
    if (await $.native.isPermissionDialogVisible(timeout: const Duration(seconds: 2))) {
      await $.native.grantPermissionWhenInUse();
    }
    await $(AppLocalizations().restore).tap();
    await $.pumpAndSettle();
  }

  Future<void> tapRenameMailbox() async {
    await $(AppLocalizations().renameFolder).tap();
  }

  Future<void> enterRenameSubFolderName(String name) async {
    await $(#rename_mailbox_dialog)
        .$(TextField)
        .enterText(name);
    await $.pumpAndSettle(duration: const Duration(seconds: 1));
  }

  Future<void> confirmRenameSubFolder() async {
    await $(#rename_mailbox_dialog)
        .$(AppLocalizations().rename.toUpperCase())
        .tap();
  }

  Future<void> tapMoveMailbox() async {
    await $(AppLocalizations().moveFolder).tap();
  }

  Future<void> tapMailboxWithName(String name) async {
    await $(name).tap();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
  }

  Future<void> tapDeleteMailbox() async {
    await $(AppLocalizations().deleteFolder).tap();
  }

  Future<void> confirmDeleteMailbox() async {
    await $(AppLocalizations().delete).tap();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
  }

  Future<void> tapAddNewFolderButton() async {
    await $(#add_new_folder_button).tap();
  }

  Future<void> tapMarkAsRead() async {
    await $(AppLocalizations().mark_as_read).tap();
    await $.pumpAndSettle();
  }

  Future<void> tapMoveFolderContentAction(String mailboxName) async {
    await $(AppLocalizations().moveFolderContent).tap();
    await $.pumpAndTrySettle();

    await $(mailboxName).tap();
    await $.pumpAndTrySettle();
  }
}