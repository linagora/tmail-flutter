

import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum ProfilesTabType {
  personalInfo,
  identities,
  follower,
}

extension ProfilesTabTypeExtension on ProfilesTabType {

  String getName(BuildContext context) {
    switch(this) {
      case ProfilesTabType.personalInfo:
        return AppLocalizations.of(context).identities;
      case ProfilesTabType.identities:
        return AppLocalizations.of(context).identities;
      case ProfilesTabType.follower:
        return AppLocalizations.of(context).identities;
    }
  }
}