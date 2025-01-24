
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum AccountMenuItem {
  profiles,
  languageAndRegion,
  alwaysReadReceipt,
  emailRules,
  forward,
  vacation,
  mailboxVisibility,
  notification,
  contactSupport,
  none;

  String getIcon(ImagePaths imagePaths) {
    switch(this) {
      case AccountMenuItem.profiles:
        return imagePaths.icProfiles;
      case AccountMenuItem.languageAndRegion:
        return imagePaths.icLanguage;
      case AccountMenuItem.alwaysReadReceipt:
        return imagePaths.icAlwaysReadReceipt;
      case AccountMenuItem.emailRules:
        return imagePaths.icEmailRules;
      case AccountMenuItem.forward:
        return imagePaths.icForward;
      case AccountMenuItem.vacation:
        return imagePaths.icVacation;
      case AccountMenuItem.mailboxVisibility:
        return imagePaths.icMailboxVisibility;
      case AccountMenuItem.notification:
        return imagePaths.icNotification;
      case AccountMenuItem.contactSupport:
        return imagePaths.icHelp;
      case AccountMenuItem.none:
        return imagePaths.icProfiles;
    }
  }

  String getName(BuildContext context) {
    switch(this) {
      case AccountMenuItem.profiles:
        return AppLocalizations.of(context).profiles;
      case AccountMenuItem.languageAndRegion:
        return AppLocalizations.of(context).language;
      case AccountMenuItem.emailRules:
        return AppLocalizations.of(context).emailRules;
      case AccountMenuItem.alwaysReadReceipt:
        return AppLocalizations.of(context).emailReadReceipts;
      case AccountMenuItem.forward:
        return AppLocalizations.of(context).forwarding;
      case AccountMenuItem.vacation:
        return AppLocalizations.of(context).vacation;
      case AccountMenuItem.mailboxVisibility:
        return AppLocalizations.of(context).folderVisibility;
      case AccountMenuItem.notification:
        return AppLocalizations.of(context).notification;
      case AccountMenuItem.contactSupport:
        return AppLocalizations.of(context).contactSupport;
      case AccountMenuItem.none:
        return AppLocalizations.of(context).profiles;
    }
  }

  String getAliasBrowser() {
    switch(this) {
      case AccountMenuItem.profiles:
        return 'profiles';
      case AccountMenuItem.languageAndRegion:
        return 'language-region';
      case AccountMenuItem.emailRules:
        return 'email-rules';
      case AccountMenuItem.alwaysReadReceipt:
        return 'email-read-receipts';
      case AccountMenuItem.forward:
        return 'forwarding';
      case AccountMenuItem.vacation:
        return 'vacation';
      case AccountMenuItem.mailboxVisibility:
        return 'folder-visibility';
      case AccountMenuItem.notification:
        return 'notification';
      case AccountMenuItem.contactSupport:
        return 'contact-support';
      case AccountMenuItem.none:
        return 'profiles';
    }
  }
}