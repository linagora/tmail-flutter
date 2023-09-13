import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum ConditionCombiner {
  and,
  or;

  String getTitle(BuildContext context) {
    switch(this) {
      case ConditionCombiner.and:
        return AppLocalizations.of(context).all;
      case ConditionCombiner.or:
        return AppLocalizations.of(context).any;
    }
  }
}