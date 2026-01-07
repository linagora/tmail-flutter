import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum LabelActionType {
  create,
  edit;

  String getContextMenuTitle(AppLocalizations appLocalizations) {
    switch (this) {
      case LabelActionType.create:
        return appLocalizations.create;
      case LabelActionType.edit:
        return appLocalizations.edit;
    }
  }

  String getModalTitle(AppLocalizations appLocalizations) {
    switch (this) {
      case LabelActionType.create:
        return appLocalizations.createANewLabel;
      case LabelActionType.edit:
        return appLocalizations.editLabel;
    }
  }

  String getModalSubtitle(AppLocalizations appLocalizations) {
    switch (this) {
      case LabelActionType.create:
        return appLocalizations.organizeYourInboxWithACustomCategory;
      case LabelActionType.edit:
        return appLocalizations.updateTheLabelName;
    }
  }

  String getModalPositiveAction(AppLocalizations appLocalizations) {
    switch (this) {
      case LabelActionType.create:
        return appLocalizations.createLabel;
      case LabelActionType.edit:
        return appLocalizations.save;
    }
  }

  String getContextMenuIcon(ImagePaths imagePaths) {
    switch (this) {
      case LabelActionType.create:
        return imagePaths.icAddNewFolder;
      case LabelActionType.edit:
        return imagePaths.icRenameMailbox;
    }
  }

  Color getPopupMenuTitleColor() => Colors.black;

  Color getPopupMenuIconColor() => AppColor.steelGrayA540;

  Color getContextMenuIconColor() =>
      AppColor.gray424244.withValues(alpha: 0.72);

  Color getContextMenuTitleColor() =>
      AppColor.gray424244.withValues(alpha: 0.9);
}
