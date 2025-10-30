import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleFavoriteTabExtension on BaseMailboxController {
  void addFavoriteFolderToMailboxList() {
    PresentationMailbox favoriteFolder = PresentationMailbox.favoriteFolder;
    if (currentContext != null) {
      favoriteFolder = favoriteFolder.copyWith(
        displayName: favoriteFolder.getDisplayName(currentContext!),
      );
    }

    _addFavoriteFolderToDefaultMailboxTree(favoriteFolder);
    _addFavoriteFolderToAllMailboxes(favoriteFolder);
  }

  void _addFavoriteFolderToDefaultMailboxTree(
    PresentationMailbox favoriteFolder,
  ) {
    final defaultMailboxNode = defaultMailboxTree.value.root;
    List<MailboxNode> currentDefaultFolders =
        defaultMailboxNode.childrenItems ?? [];

    if (currentDefaultFolders.isEmpty) {
      currentDefaultFolders.add(MailboxNode(favoriteFolder));
    } else {
      currentDefaultFolders.insertAfterInbox(MailboxNode(favoriteFolder));
    }

    defaultMailboxTree.value = MailboxTree(
      defaultMailboxNode.copyWith(children: currentDefaultFolders),
    );
  }

  void _addFavoriteFolderToAllMailboxes(PresentationMailbox favoriteFolder) {
    final alreadyExists = allMailboxes.any(
      (mailbox) => mailbox.id == favoriteFolder.id,
    );
    if (alreadyExists) return;

    allMailboxes.add(favoriteFolder);
  }
}
