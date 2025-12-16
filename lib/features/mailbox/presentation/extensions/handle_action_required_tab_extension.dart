import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_ai_action_extension.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleActionRequiredTabExtension on BaseMailboxController {
  void setUpActionRequiredFolder(
    MailboxDashBoardController dashboardController,
  ) {
    if (!dashboardController.isAiCapabilitySupported) return;

    dashboardController.actionRequiredFolderController.getCountEmails(
      session: dashboardController.sessionCurrent,
      accountId: dashboardController.accountId.value,
    );
  }

  void onActionRequiredFolderCountChanged(int count) {
    if (count > 0) {
      _addActionRequiredFolder(count);
    } else {
      _removeActionRequiredFolder();
    }
  }

  void _addActionRequiredFolder(int count) {
    final folder = _buildActionRequiredFolder(count);

    _addToDefaultMailboxTree(folder);
    _addToAllMailboxes(folder);
  }

  PresentationMailbox _buildActionRequiredFolder(int count) {
    final base = PresentationMailbox.actionRequiredFolder;

    return base.copyWith(
      displayName:
          currentContext != null ? base.getDisplayName(currentContext!) : null,
      totalEmails: TotalEmails(UnsignedInt(count)),
      unreadEmails: UnreadEmails(UnsignedInt(count)),
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

  void _removeActionRequiredFolder() {
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

  bool _allMailboxesContains(MailboxId id) {
    return allMailboxes.any((mailbox) => mailbox.id == id);
  }
}
