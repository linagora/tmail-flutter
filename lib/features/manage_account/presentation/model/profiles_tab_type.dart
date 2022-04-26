

import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum ProfilesTabType {
  identities,
}

extension ProfilesTabTypeExtension on ProfilesTabType {

  String getName(BuildContext context) {
    switch(this) {
      case ProfilesTabType.identities:
        return AppLocalizations.of(context).identities;
    }
  }
}