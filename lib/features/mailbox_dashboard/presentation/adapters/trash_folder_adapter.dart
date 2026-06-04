import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/adapters/empty_folder_adapter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/adapters/empty_folder_tag.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TrashFolderAdapter implements EmptyFolderAdapter {
  const TrashFolderAdapter();

  @override
  String get tag => EmptyFolderTag.trash;

  @override
  String get teamMailboxRole => PresentationMailbox.trashRole;

  @override
  String successMessage(AppLocalizations l10n) =>
      l10n.toast_message_empty_trash_folder_success;

  @override
  String failureMessage(AppLocalizations l10n) => l10n.emptyTrashFolderFailed;

  @override
  String? subfoldersAllDeletedMessage(AppLocalizations l10n) =>
      l10n.clearTrashSubfoldersSuccess;

  @override
  String? subfoldersPartiallyDeletedMessage(AppLocalizations l10n) =>
      l10n.clearTrashSubfoldersPartialSuccess;

  @override
  String? subfoldersDeleteFailedMessage(AppLocalizations l10n) =>
      l10n.clearTrashSubfoldersFailed;
}
