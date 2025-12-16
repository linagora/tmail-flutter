import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleActionRequiredTabExtension on BaseMailboxController {
  void addActionRequiredFolder() {
    final folder = _buildActionRequiredFolder();
    _addToDefaultMailboxTree(folder);
    _addToAllMailboxes(folder);
  }

  PresentationMailbox _buildActionRequiredFolder() {
    final base = PresentationMailbox.actionRequiredFolder;

    return base.copyWith(
      displayName:
          currentContext != null ? base.getDisplayName(currentContext!) : null,
    );
  }

  void _addToDefaultMailboxTree(PresentationMailbox folder) {
    final root = defaultMailboxTree.value.root;
    final children = List<MailboxNode>.from(root.childrenItems ?? []);

    children.insertAfterStarredOrInbox(MailboxNode(folder));

    defaultMailboxTree.value = MailboxTree(
      root.copyWith(children: children),
    );
  }

  void _addToAllMailboxes(PresentationMailbox folder) {
    if (_allMailboxesContains(folder.id)) return;
    allMailboxes.add(folder);
  }

  bool _allMailboxesContains(MailboxId id) {
    return allMailboxes.any((mailbox) => mailbox.id == id);
  }
}
