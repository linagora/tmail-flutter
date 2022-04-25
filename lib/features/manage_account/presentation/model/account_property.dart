
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum AccountProperty {
  profiles
}

extension AccountPropertyExtension on AccountProperty {

  String getIcon(ImagePaths imagePaths) {
    switch(this) {
      case AccountProperty.profiles:
        return imagePaths.icProfiles;
    }
  }

  String getName(BuildContext context) {
    switch(this) {
      case AccountProperty.profiles:
        return AppLocalizations.of(context).profiles;
    }
  }
}