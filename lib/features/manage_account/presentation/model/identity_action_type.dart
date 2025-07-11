
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum IdentityActionType {
  create,
  edit;

  String getTitle(AppLocalizations appLocalizations) {
    switch (this) {
      case IdentityActionType.create:
        return appLocalizations.createNewIdentity;
      case IdentityActionType.edit:
        return appLocalizations.edit_identity;
    }
  }

  String getPositiveButtonTitle(AppLocalizations appLocalizations) {
    switch (this) {
      case IdentityActionType.create:
        return appLocalizations.create;
      case IdentityActionType.edit:
        return appLocalizations.save;
    }
  }
}