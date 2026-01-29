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
    final newDefaultTree = _addToDefaultMailboxTree(
      folder: folder,
      currentDefaultTree: mailboxCollection.defaultTree,
    );
    final newAllMailboxes = _addToAllMailboxes(
      folder: folder,
      currentAllMailboxes: mailboxCollection.allMailboxes,
    );

    return mailboxCollection.copyWith(
      defaultTree: newDefaultTree,
      allMailboxes: newAllMailboxes,
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

  void removeActionRequiredFolder() {
    final folder = PresentationMailbox.actionRequiredFolder;
    _removeFromDefaultMailboxTree(folder.id);
    _removeFromAllMailboxes(folder.id);
  }

  void _removeFromDefaultMailboxTree(MailboxId folderId) {
    final root = defaultMailboxTree.value.root;
    final children = List<MailboxNode>.from(root.childrenItems ?? [])
      ..removeWhere((node) => node.item.id == folderId);

    defaultMailboxTree.value = MailboxTree(
      root.copyWith(children: children),
    );
  }

  void _removeFromAllMailboxes(MailboxId folderId) {
    allMailboxes.removeWhere((mailbox) => mailbox.id == folderId);
  }
}
