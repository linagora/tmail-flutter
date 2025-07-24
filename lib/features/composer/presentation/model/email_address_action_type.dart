
import 'package:core/presentation/resources/image_paths.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailAddressActionType {
  copy,
  modify,
  createRule;

  String getContextMenuTitle(AppLocalizations appLocalizations) {
    switch(this) {
      case EmailAddressActionType.copy:
        return appLocalizations.copy;
      case EmailAddressActionType.modify:
        return appLocalizations.modifyEmailAddress;
      case EmailAddressActionType.createRule:
        return appLocalizations.createARule;
    }
  }

  String getContextMenuIcon(ImagePaths imagePaths) {
    switch(this) {
      case EmailAddressActionType.copy:
        return imagePaths.icCopy;
      case EmailAddressActionType.modify:
        return imagePaths.icEditRule;
      case EmailAddressActionType.createRule:
        return imagePaths.icQuickCreatingRule;
    }
  }
}