import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_view.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_mailbox_folder_robot.dart';

class MailboxFolderRobot extends CoreRobot implements AbstractMailboxFolderRobot {
  final _l10n = AppLocalizations();

  MailboxFolderRobot(super.$);

  @override
  Future<void> tapAddNewFolderButton() async {
    await $(#add_new_folder_button).tap();
  }

  @override
  Future<void> tapCreateNewSubFolder() async {
    await $(_l10n.newSubfolder).tap();
  }

  @override
  Future<void> enterNewFolderName(String name) async {
    await $(MailboxCreatorView)
        .$(TextFieldBuilder)
        .enterText(name);
  }

  @override
  Future<void> confirmCreateNewFolder() async {
    await $(MailboxCreatorView)
        .$(_l10n.createFolder)
        .tap();
  }

  @override
  Future<void> tapRenameMailbox() async {
    await $(_l10n.renameFolder).tap();
  }

  @override
  Future<void> enterRenameSubFolderName(String name) async {
    await $(#rename_mailbox_dialog)
        .$(TextField)
        .enterText(name);
    await $.pumpAndSettle(duration: const Duration(seconds: 1));
  }

  @override
  Future<void> confirmRenameSubFolder() async {
    await $(#rename_mailbox_dialog)
        .$(_l10n.rename.toUpperCase())
        .tap();
  }

  @override
  Future<void> tapMoveMailbox() async {
    await $(_l10n.moveFolder).tap();
  }

  @override
  Future<void> tapDeleteMailbox() async {
    await $(_l10n.deleteFolder).tap();
  }

  @override
  Future<void> confirmDeleteMailbox() async {
    await $(_l10n.delete).tap();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
  }

  @override
  Future<void> tapHideMailbox() async {
    await $(_l10n.hideFolder).tap();
  }

  @override
  Future<void> tapMoveFolderContentAction(PatrolFinder targetMailbox) async {
    await $(_l10n.moveFolderContent).tap();
    await $.pumpAndTrySettle();
    await targetMailbox.tap();
    await $.pumpAndTrySettle();
  }
}
