
import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum CreatorActionType {
  create,
  edit;

  String getTitle(AppLocalizations appLocalizations) {
    switch(this) {
      case CreatorActionType.create:
        return appLocalizations.createANewRule;
      case CreatorActionType.edit:
        return appLocalizations.editRule.capitalizeFirstEach;
    }
  }

  String getActionName(AppLocalizations appLocalizations) {
    switch(this) {
      case CreatorActionType.create:
        return appLocalizations.createRule;
      case CreatorActionType.edit:
        return appLocalizations.save;
    }
  }
}