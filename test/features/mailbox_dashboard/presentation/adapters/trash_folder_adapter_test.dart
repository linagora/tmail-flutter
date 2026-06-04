import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/adapters/empty_folder_tag.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/adapters/trash_folder_adapter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import 'trash_folder_adapter_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AppLocalizations>()])
void main() {
  late TrashFolderAdapter adapter;
  late MockAppLocalizations mockL10n;

  setUp(() {
    adapter = const TrashFolderAdapter();
    mockL10n = MockAppLocalizations();
  });

  group('TrashFolderAdapter', () {
    test('tag equals EmptyFolderTag.trash', () {
      expect(adapter.tag, EmptyFolderTag.trash);
    });

    test('teamMailboxRole is trashRole', () {
      expect(adapter.teamMailboxRole, PresentationMailbox.trashRole);
    });

    test('successMessage delegates to toast_message_empty_trash_folder_success', () {
      when(mockL10n.toast_message_empty_trash_folder_success).thenReturn('All messages deleted');
      expect(adapter.successMessage(mockL10n), 'All messages deleted');
    });

    test('failureMessage delegates to emptyTrashFolderFailed', () {
      when(mockL10n.emptyTrashFolderFailed).thenReturn('Empty trash failed');
      expect(adapter.failureMessage(mockL10n), 'Empty trash failed');
    });

    test('subfoldersAllDeletedMessage is non-null and delegates to clearTrashSubfoldersSuccess', () {
      when(mockL10n.clearTrashSubfoldersSuccess).thenReturn('Trash subfolders deleted');
      expect(adapter.subfoldersAllDeletedMessage(mockL10n), 'Trash subfolders deleted');
    });

    test('subfoldersPartiallyDeletedMessage is non-null and delegates to clearTrashSubfoldersPartialSuccess', () {
      when(mockL10n.clearTrashSubfoldersPartialSuccess).thenReturn('Some subfolders not deleted');
      expect(adapter.subfoldersPartiallyDeletedMessage(mockL10n), 'Some subfolders not deleted');
    });

    test('subfoldersDeleteFailedMessage is non-null and delegates to clearTrashSubfoldersFailed', () {
      when(mockL10n.clearTrashSubfoldersFailed).thenReturn('Failed to delete subfolders');
      expect(adapter.subfoldersDeleteFailedMessage(mockL10n), 'Failed to delete subfolders');
    });
  });
}
