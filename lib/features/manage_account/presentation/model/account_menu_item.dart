
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum AccountMenuItem {
  profiles,
  languageAndRegion,
  emailRules,
  forward,
  vacation;

  String getIcon(ImagePaths imagePaths) {
    switch(this) {
      case AccountMenuItem.profiles:
        return imagePaths.icProfiles;
      case AccountMenuItem.languageAndRegion:
        return imagePaths.icLanguage;
      case AccountMenuItem.emailRules:
        return imagePaths.icEmailRules;
      case AccountMenuItem.forward:
        return imagePaths.icForward;
      case AccountMenuItem.configuration:
        return imagePaths.icConfiguration;
    }
  }

  String getName(BuildContext context) {
    switch(this) {
      case AccountMenuItem.profiles:
        return AppLocalizations.of(context).profiles;
      case AccountMenuItem.languageAndRegion:
        return AppLocalizations.of(context).languageAndRegion;
      case AccountMenuItem.emailRules:
        return AppLocalizations.of(context).emailRules;
      case AccountMenuItem.forward:
        return AppLocalizations.of(context).forwarding;
      case AccountMenuItem.configuration:
        return AppLocalizations.of(context).configuration;
    }
  }
}