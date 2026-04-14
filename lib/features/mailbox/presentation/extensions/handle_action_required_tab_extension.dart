import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_collection.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleActionRequiredTabExtension on BaseMailboxController {
  MailboxCollection addActionRequiredFolder({
    required MailboxCollection mailboxCollection,
  }) {
    final folder = _buildActionRequiredFolder();
    return mailboxCollection.copyWith(
      defaultTree: _addToDefaultMailboxTree(
        folder: folder,
        currentDefaultTree: mailboxCollection.defaultTree,
      ),
      allMailboxes: _addToAllMailboxes(
        folder: folder,
        currentAllMailboxes: mailboxCollection.allMailboxes,
      ),
    );
  }

  PresentationMailbox _buildActionRequiredFolder() {
    final base = PresentationMailbox.actionRequiredFolder;

    return base.copyWith(
      displayName:
          currentContext != null ? base.getDisplayName(currentContext!) : null,
    );
  }

  MailboxTree _addToDefaultMailboxTree({
    required PresentationMailbox folder,
    required MailboxTree currentDefaultTree,
  }) {
    final root = currentDefaultTree.root;
    final children = List<MailboxNode>.from(root.childrenItems ?? []);
    if (children.any((node) => node.item.id == folder.id)) {
      return currentDefaultTree;
    }

    children.insertAfterStarredOrInbox(MailboxNode(folder));

    return MailboxTree(root.copyWith(children: children));
  }

  List<PresentationMailbox> _addToAllMailboxes({
    required PresentationMailbox folder,
    required List<PresentationMailbox> currentAllMailboxes,
  }) {
    if (_allMailboxesContains(
      id: folder.id,
      currentAllMailboxes: currentAllMailboxes,
    )) {
      return currentAllMailboxes;
    }
    return [...currentAllMailboxes, folder];
  }

  bool _allMailboxesContains({
    required MailboxId id,
    required List<PresentationMailbox> currentAllMailboxes,
  }) {
    return currentAllMailboxes.any((mailbox) => mailbox.id == id);
  }

  MailboxCollection removeActionRequiredFolder({
    required MailboxCollection mailboxCollection,
  }) {
    return mailboxCollection.copyWith(
      defaultTree: _removeFromDefaultMailboxTree(
        folderId: PresentationMailbox.actionRequiredFolder.id,
        currentDefaultTree: mailboxCollection.defaultTree,
      ),
      allMailboxes: _removeFromAllMailboxes(
        folderId: PresentationMailbox.actionRequiredFolder.id,
        currentAllMailboxes: mailboxCollection.allMailboxes,
      ),
    );
  }

  MailboxTree _removeFromDefaultMailboxTree({
    required MailboxId folderId,
    required MailboxTree currentDefaultTree,
  }) {
    final root = currentDefaultTree.root;
    final children = List<MailboxNode>.from(root.childrenItems ?? [])
      ..removeWhere((node) => node.item.id == folderId);
    return MailboxTree(root.copyWith(children: children));
  }

  List<PresentationMailbox> _removeFromAllMailboxes({
    required MailboxId folderId,
    required List<PresentationMailbox> currentAllMailboxes,
  }) {
    return currentAllMailboxes
        .where((mailbox) => mailbox.id != folderId)
        .toList();
  }
}
