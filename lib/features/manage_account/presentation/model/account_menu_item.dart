
import 'package:core/presentation/resources/image_paths.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum AccountMenuItem {
  profiles,
  languageAndRegion,
  preferences,
  emailRules,
  forward,
  vacation,
  mailboxVisibility,
  notification,
  contactSupport,
  storage,
  keyboardShortcuts,
  signOut,
  none;

  String getIcon(ImagePaths imagePaths) {
    switch(this) {
      case AccountMenuItem.profiles:
        return imagePaths.icProfiles;
      case AccountMenuItem.languageAndRegion:
        return imagePaths.icLanguage;
      case AccountMenuItem.preferences:
        return imagePaths.icPreferences;
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
      case AccountMenuItem.storage:
        return imagePaths.icStorage;
      case AccountMenuItem.keyboardShortcuts:
        return imagePaths.icKeyboard;
      case AccountMenuItem.signOut:
        return imagePaths.icSignOut;
      case AccountMenuItem.none:
        return imagePaths.icProfiles;
    }
  }

  String getName(AppLocalizations appLocalizations) {
    switch(this) {
      case AccountMenuItem.profiles:
        return appLocalizations.profiles;
      case AccountMenuItem.languageAndRegion:
        return appLocalizations.language;
      case AccountMenuItem.emailRules:
        return appLocalizations.emailRules;
      case AccountMenuItem.preferences:
        return appLocalizations.preferences;
      case AccountMenuItem.forward:
        return appLocalizations.forwarding;
      case AccountMenuItem.vacation:
        return appLocalizations.vacation;
      case AccountMenuItem.mailboxVisibility:
        return appLocalizations.folderVisibility;
      case AccountMenuItem.notification:
        return appLocalizations.notification;
      case AccountMenuItem.contactSupport:
        return appLocalizations.contactSupport;
      case AccountMenuItem.storage:
        return appLocalizations.storageQuotas;
      case AccountMenuItem.keyboardShortcuts:
        return appLocalizations.keyboardShortcuts;
      case AccountMenuItem.signOut:
        return appLocalizations.sign_out;
      case AccountMenuItem.none:
        return appLocalizations.profiles;
    }
  }
  
  String getExplanation(AppLocalizations appLocalizations) {
    switch(this) {
      case AccountMenuItem.profiles:
        return appLocalizations.identitiesSettingExplanation;
      case AccountMenuItem.languageAndRegion:
        return appLocalizations.languageSubtitle;
      case AccountMenuItem.emailRules:
        return appLocalizations.emailRuleSettingExplanation;
      case AccountMenuItem.forward:
        return appLocalizations.forwardingSettingExplanation;
      case AccountMenuItem.vacation:
        return appLocalizations.vacationSettingExplanation;
      case AccountMenuItem.mailboxVisibility:
        return appLocalizations.folderVisibilitySubtitle;
      case AccountMenuItem.storage:
        return appLocalizations.storageSettingExplanation;
      case AccountMenuItem.notification:
        return appLocalizations.allowsTwakeMailToNotifyYouWhenANewMessageArrivesOnYourPhone;
      case AccountMenuItem.keyboardShortcuts:
        return appLocalizations.keyboardShortcutsSettingExplanation;
      default:
        return '';
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
      case AccountMenuItem.preferences:
        return 'preferences';
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
      case AccountMenuItem.storage:
        return 'storage';
      case AccountMenuItem.keyboardShortcuts:
        return 'keyboard-shortcuts';
      case AccountMenuItem.signOut:
        return 'sign-out';
      case AccountMenuItem.none:
        return 'profiles';
    }
  }
}