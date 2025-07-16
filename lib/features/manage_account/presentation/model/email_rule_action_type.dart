
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailRuleActionType {
  add,
  edit,
  delete;

  String getName(AppLocalizations appLocalizations) {
    switch(this) {
      case EmailRuleActionType.add:
        return appLocalizations.addNewRule;
      case EmailRuleActionType.edit:
        return appLocalizations.editRule;
      case EmailRuleActionType.delete:
        return appLocalizations.deleteRule;
    }
  }

  String getIcon(ImagePaths imagePaths) {
    switch(this) {
      case EmailRuleActionType.add:
        return imagePaths.icAddNewFolder;
      case EmailRuleActionType.edit:
        return imagePaths.icEdit;
      case EmailRuleActionType.delete:
        return imagePaths.icDeleteComposer;
    }
  }

  Color getIconColor() {
    if (this == EmailRuleActionType.delete) {
      return AppColor.redFF3347;
    } else {
      return AppColor.gray424244.withOpacity(0.72);
    }
  }

  Color getNameColor() {
    if (this == EmailRuleActionType.delete) {
      return AppColor.redFF3347;
    } else {
      return AppColor.gray424244.withOpacity(0.79);
    }
  }
}