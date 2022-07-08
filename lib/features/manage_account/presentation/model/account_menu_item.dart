
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum AccountMenuItem {
  profiles,
  languageAndRegion
}

extension AccountMenuItemExtension on AccountMenuItem {

  String getIcon(ImagePaths imagePaths) {
    switch(this) {
      case AccountMenuItem.profiles:
        return imagePaths.icProfiles;
      case AccountMenuItem.languageAndRegion:
        return imagePaths.icLanguage;
    }
  }

  String getName(BuildContext context) {
    switch(this) {
      case AccountMenuItem.profiles:
        return AppLocalizations.of(context).profiles;
      case AccountMenuItem.languageAndRegion:
        return AppLocalizations.of(context).languageAndRegion;
    }
  }
}