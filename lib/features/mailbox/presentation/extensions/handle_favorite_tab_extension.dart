import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_collection.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleFavoriteTabExtension on BaseMailboxController {
  MailboxCollection addFavoriteFolderToMailboxList({
    required MailboxCollection mailboxCollection,
  }) {
    PresentationMailbox favoriteFolder = PresentationMailbox.favoriteFolder;
    if (currentContext != null) {
      favoriteFolder = favoriteFolder.copyWith(
        displayName: favoriteFolder.getDisplayName(currentContext!),
      );
    }

    final newDefaultTree = _addFavoriteFolderToDefaultMailboxTree(
      favoriteFolder: favoriteFolder,
      defaultTree: mailboxCollection.defaultTree,
    );
    final newAllMailboxes = _addFavoriteFolderToAllMailboxes(
      favoriteFolder: favoriteFolder,
      allMailboxes: mailboxCollection.allMailboxes,
    );

    return mailboxCollection.copyWith(
      defaultTree: newDefaultTree,
      allMailboxes: newAllMailboxes,
    );
  }

  MailboxTree _addFavoriteFolderToDefaultMailboxTree({
    required PresentationMailbox favoriteFolder,
    required MailboxTree defaultTree,
  }) {
    final defaultMailboxNode = defaultTree.root;
    final currentDefaultFolders =
        List<MailboxNode>.from(defaultMailboxNode.childrenItems ?? []);

    if (currentDefaultFolders.isEmpty) {
      currentDefaultFolders.add(MailboxNode(favoriteFolder));
    } else {
      currentDefaultFolders.insertAfterInbox(MailboxNode(favoriteFolder));
    }

    return MailboxTree(
      defaultMailboxNode.copyWith(children: currentDefaultFolders),
    );
  }

  List<PresentationMailbox> _addFavoriteFolderToAllMailboxes({
    required PresentationMailbox favoriteFolder,
    required List<PresentationMailbox> allMailboxes,
  }) {
    final alreadyExists = allMailboxes.any(
      (mailbox) => mailbox.id == favoriteFolder.id,
    );
    if (alreadyExists) return allMailboxes;

    return [...allMailboxes, favoriteFolder];
  }
}
