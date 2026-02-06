import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum LabelActionType {
  create,
  edit,
  delete;

  String getContextMenuTitle(AppLocalizations appLocalizations) {
    switch (this) {
      case LabelActionType.create:
        return appLocalizations.create;
      case LabelActionType.edit:
        return appLocalizations.edit;
      case LabelActionType.delete:
        return appLocalizations.delete;
    }
  }

  String getModalTitle(AppLocalizations appLocalizations) {
    switch (this) {
      case LabelActionType.create:
        return appLocalizations.createANewLabel;
      case LabelActionType.edit:
        return appLocalizations.editLabel;
      case LabelActionType.delete:
        return appLocalizations.deleteLabel;
    }
  }

  String getModalSubtitle(AppLocalizations appLocalizations) {
    switch (this) {
      case LabelActionType.create:
        return appLocalizations.organizeYourInboxWithACustomCategory;
      case LabelActionType.edit:
        return appLocalizations.updateTheLabelName;
      default:
        return '';
    }
  }

  String getModalPositiveAction(AppLocalizations appLocalizations) {
    switch (this) {
      case LabelActionType.create:
        return appLocalizations.createLabel;
      case LabelActionType.edit:
        return appLocalizations.save;
      case LabelActionType.delete:
        return '';
    }
  }

  Key? getModalPositiveActionKey() {
    switch (this) {
      case LabelActionType.create:
        return const Key('create_label_button_action');
      case LabelActionType.edit:
        return const Key('save_label_button_action');
      case LabelActionType.delete:
        return null;
    }
  }

  String getContextMenuIcon(ImagePaths imagePaths) {
    switch (this) {
      case LabelActionType.create:
        return imagePaths.icAddNewFolder;
      case LabelActionType.edit:
        return imagePaths.icRenameMailbox;
      case LabelActionType.delete:
        return imagePaths.icDeleteMailbox;
    }
  }

  Color getPopupMenuTitleColor() {
    switch (this) {
      case LabelActionType.delete:
        return AppColor.redFF3347;
      default:
        return Colors.black;
    }
  }

  Color getPopupMenuIconColor() {
    switch (this) {
      case LabelActionType.delete:
        return AppColor.redFF3347;
      default:
        return AppColor.steelGrayA540;
    }
  }

  Color getContextMenuIconColor() {
    switch (this) {
      case LabelActionType.delete:
        return AppColor.redFF3347;
      default:
        return AppColor.gray424244.withValues(alpha: 0.72);
    }
  }

  Color getContextMenuTitleColor() {
    switch (this) {
      case LabelActionType.delete:
        return AppColor.redFF3347;
      default:
        return AppColor.gray424244.withValues(alpha: 0.9);
    }
  }
}
