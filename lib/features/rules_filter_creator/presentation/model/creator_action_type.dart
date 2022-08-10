
import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum CreatorActionType {
  create;

  String getTitle(BuildContext context) {
    switch(this) {
      case CreatorActionType.create:
        return AppLocalizations.of(context).createNewRule.inCaps;
    }
  }

  String getActionName(BuildContext context) {
    switch(this) {
      case CreatorActionType.create:
        return AppLocalizations.of(context).create.inCaps;
    }
  }
}