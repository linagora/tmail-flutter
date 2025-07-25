
import 'package:core/presentation/resources/image_paths.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailAddressActionType {
  copy,
  edit,
  createRule;

  String getContextMenuTitle(AppLocalizations appLocalizations) {
    switch(this) {
      case EmailAddressActionType.copy:
        return appLocalizations.copy;
      case EmailAddressActionType.edit:
        return appLocalizations.edit;
      case EmailAddressActionType.createRule:
        return appLocalizations.createARule;
    }
  }

  String getContextMenuIcon(ImagePaths imagePaths) {
    switch(this) {
      case EmailAddressActionType.copy:
        return imagePaths.icCopy;
      case EmailAddressActionType.edit:
        return imagePaths.icEditRule;
      case EmailAddressActionType.createRule:
        return imagePaths.icQuickCreatingRule;
    }
  }
}