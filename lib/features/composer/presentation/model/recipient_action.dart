
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum RecipientAction {
  changeEmailAddress;

  String getTitle(BuildContext context) {
    switch(this) {
      case RecipientAction.changeEmailAddress:
        return AppLocalizations.of(context).changeEmailAddress;
    }
  }

  String getIcon(ImagePaths imagePaths) {
    switch(this) {
      case RecipientAction.changeEmailAddress:
        return imagePaths.icEdit;
    }
  }
}