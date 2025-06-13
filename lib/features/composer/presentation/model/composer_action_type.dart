import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum ComposerActionType {
  markAsImportant,
  requestReadReceipt,
  saveAsDraft,
  saveAsTemplate,
  delete;

  String getContextMenuTitle(AppLocalizations appLocalizations) {
    switch (this) {
      case ComposerActionType.markAsImportant:
        return appLocalizations.markAsImportant;
      case ComposerActionType.requestReadReceipt:
        return appLocalizations.requestReadReceipt;
      case ComposerActionType.saveAsDraft:
        return appLocalizations.saveAsDraft;
      case ComposerActionType.saveAsTemplate:
        return appLocalizations.saveAsTemplate;
      case ComposerActionType.delete:
        return appLocalizations.delete;
    }
  }

  String getContextMenuIcon(ImagePaths imagePath) {
    switch (this) {
      case ComposerActionType.markAsImportant:
        return imagePath.icMarkAsImportant;
      case ComposerActionType.requestReadReceipt:
        return imagePath.icReadReceipt;
      case ComposerActionType.saveAsDraft:
        return imagePath.icSaveToDraft;
      case ComposerActionType.saveAsTemplate:
        return imagePath.icSaveToDraft;
      case ComposerActionType.delete:
        return imagePath.icDeleteMailbox;
    }
  }

  Color getContextMenuTitleColor() {
    switch (this) {
      case ComposerActionType.delete:
        return AppColor.redFF3347;
      default:
        return Colors.black;
    }
  }

  Color getContextMenuIconColor() {
    switch (this) {
      case ComposerActionType.delete:
        return AppColor.redFF3347;
      default:
        return AppColor.steelGrayA540;
    }
  }

  Key getContextMenuItemKey() {
    switch (this) {
      case ComposerActionType.markAsImportant:
        return const Key('mark_as_important_popup_item');
      case ComposerActionType.requestReadReceipt:
        return const Key('read_receipt_popup_item');
      case ComposerActionType.saveAsDraft:
        return const Key('save_as_draft_popup_item');
      case ComposerActionType.saveAsTemplate:
        return const Key('save_as_template_popup_item');
      case ComposerActionType.delete:
        return const Key('delete_popup_item');
    }
  }
}
