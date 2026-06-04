import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

abstract interface class EmptyFolderAdapter {
  /// Explicit routing key emitted at the trigger point.
  /// Must match what [EmptyFolderRequest.tag] carries when this adapter's
  /// action is triggered — independent of mailbox role.
  String get tag;

  /// Role string passed to [isFirstLevelTeamSystemFolder] to detect team mailbox variants.
  String get teamMailboxRole;

  String successMessage(AppLocalizations l10n);
  String failureMessage(AppLocalizations l10n);

  /// Returns null when this folder type has no subfolder-specific message.
  String? subfoldersAllDeletedMessage(AppLocalizations l10n);
  String? subfoldersPartiallyDeletedMessage(AppLocalizations l10n);
  String? subfoldersDeleteFailedMessage(AppLocalizations l10n);
}
