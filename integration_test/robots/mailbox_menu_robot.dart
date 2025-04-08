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

import '../base/core_robot.dart';
import '../integration_test/exceptions/mailbox/null_quota_exception.dart';

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

  Future<void> longPressMailboxWithName(String name) async {
    await $(name).longPress();
    await $.pumpAndSettle();
  }

  Future<void> tapCreateNewSubFolder() async {
    await $(AppLocalizations().newSubfolder).tap();
  }

  Future<void> enterNewSubFolderName(String name) async {
    await $(MailboxCreatorView)
      .$(TextFieldBuilder)
      .enterText(name);
  }

  Future<void> confirmCreateNewSubFolder() async {
    await $(MailboxCreatorView)
      .$(AppLocalizations().done)
      .tap();
  }

  Future<void> expandMailboxWithName(String name) async {
    await $(MailboxItemWidget)
      .which<MailboxItemWidget>((widget) {
        return widget.mailboxNode.item.name?.name.toLowerCase() ==
          name.toLowerCase();
      })
      .$(TMailButtonWidget)
      .which<TMailButtonWidget>((widget) {
        return widget.icon == ImagePaths().icArrowRight;
      })
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
    await $(IconButton)
      .which<IconButton>((widget) {
        return widget.tooltip == AppLocalizations().close;
      })
      .tap();
  }

  Future<int> getUsedQuota() async {
    final quotaController = Get.find<QuotasController>();
    final usedQuota = quotaController.octetsQuota.value?.used?.value.toInt();
    if (usedQuota == null) throw NullQuotaException();

    return usedQuota;
  }

  Future<void> refreshQuota() async {
    Get.find<QuotasController>().refreshQuota();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
  }
}