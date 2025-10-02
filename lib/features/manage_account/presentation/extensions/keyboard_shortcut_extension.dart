import 'package:core/presentation/resources/image_paths.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/keyboard_shortcuts/keyboard_shortcut.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension ShortcutContextText on ShortcutContext {
  String getDisplayName(AppLocalizations appLocalizations) {
    switch (this) {
      case ShortcutContext.mailComposer:
        return appLocalizations.mailComposer;
      case ShortcutContext.focusOnSearch:
        return appLocalizations.focusOnSearch;
      case ShortcutContext.openedModal:
        return appLocalizations.openedModal;
      case ShortcutContext.mailboxList:
        return appLocalizations.mailboxList;
      case ShortcutContext.openedMailView:
        return appLocalizations.openedMailView;
      case ShortcutContext.mailboxListWithSelectedEmail:
        return appLocalizations.mailboxListWithSelectedMail;
    }
  }
}

extension ShortcutCategoryText on ShortcutCategory {
  String getDisplayName(
    AppLocalizations appLocalizations, {
    bool isDesktop = false,
  }) {
    switch (this) {
      case ShortcutCategory.navigationAndClosing:
        return !isDesktop
            ? appLocalizations.navigation
            : appLocalizations.navigationAndClosing;
      case ShortcutCategory.readingAndReplying:
        return !isDesktop
            ? appLocalizations.reading
            : appLocalizations.readingAndReplying;
      case ShortcutCategory.messageManagementAndSelection:
        return !isDesktop
            ? appLocalizations.message
            : appLocalizations.messageManagementAndSelection;
    }
  }

  String getIcon(ImagePaths imagePaths) {
    switch (this) {
      case ShortcutCategory.navigationAndClosing:
        return imagePaths.icNavigation;
      case ShortcutCategory.readingAndReplying:
        return imagePaths.icReading;
      case ShortcutCategory.messageManagementAndSelection:
        return imagePaths.icMessage;
    }
  }

  double getTabWidth() {
    switch (this) {
      case ShortcutCategory.navigationAndClosing:
        return 174;
      case ShortcutCategory.readingAndReplying:
        return 164;
      case ShortcutCategory.messageManagementAndSelection:
        return 280;
    }
  }
}
