import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/email_selection_action_type.dart';

void main() {
  final imagePaths = ImagePaths();

  test('keeps archive email actions separate from the archive folder icon', () {
    final archiveMailbox = PresentationMailbox(
      MailboxId(Id('archive')),
      role: Role('archive'),
    );

    expect(
      archiveMailbox.getMailboxIcon(imagePaths),
      'assets/images/ic_archives_folder.svg',
    );
    expect(
      EmailActionType.archiveMessage.getIcon(imagePaths),
      'assets/images/ic_mailbox_archived_action.svg',
    );
    expect(
      EmailSelectionActionType.archiveMessage.getIcon(imagePaths),
      'assets/images/ic_mailbox_archived_action.svg',
    );
  });

  test('keeps empty-mailbox actions separate from the trash folder icon', () {
    expect(imagePaths.icMailboxTrash, 'assets/images/ic_trash_folder.svg');
    expect(
      MailboxActions.emptyTrash.getContextMenuIcon(imagePaths),
      'assets/images/ic_mailbox_trash_action.svg',
    );
    expect(
      MailboxActions.emptySpam.getContextMenuIcon(imagePaths),
      'assets/images/ic_mailbox_trash_action.svg',
    );
  });

  test('exposes the legacy-sized drafts icon for non-folder UI', () {
    expect(
      imagePaths.icMailboxDraftsAction,
      'assets/images/ic_mailbox_drafts_action.svg',
    );
  });

  testWidgets('bundles the legacy action icons used outside folders',
      (tester) async {
    final actionIconPaths = [
      imagePaths.icMailboxArchivedAction,
      imagePaths.icMailboxDraftsAction,
      imagePaths.icMailboxTrashAction,
    ];

    for (final iconPath in actionIconPaths) {
      final svg = await rootBundle.loadString(iconPath);
      expect(svg, contains('<svg width="20" height="20"'));
    }
  });
}
