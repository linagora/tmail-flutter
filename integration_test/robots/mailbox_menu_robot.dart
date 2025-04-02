
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/label_mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';

class MailboxMenuRobot extends CoreRobot {
  MailboxMenuRobot(super.$);

  Future<void> openAppGrid() async {
    await $(#toggle_app_grid_button).tap();
  }

  Future<void> openFolderByName(String name) async {
    await $(MailboxItemWidget)
      .$(LabelMailboxItemWidget)
      .$(find.text(name))
      .tap();
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
}