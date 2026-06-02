import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_mailbox_action_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/execute_delete_trash_subfolders_extension.dart';

/// Combines [ConsumerWidget] (for Riverpod delete-subfolders access) and
/// [Obx] (for GetX reactive state) to render a single [MailboxItemWidget].
class MailboxItemConsumerWidget extends ConsumerWidget {
  final MailboxNode mailboxNode;
  final MailboxController controller;
  final bool isHighlighted;

  const MailboxItemConsumerWidget({
    super.key,
    required this.mailboxNode,
    required this.controller,
    required this.isHighlighted,
  });

  VoidCallback? _buildDeleteSubfoldersCallback(
    BuildContext context,
    WidgetRef ref,
    PresentationMailbox mailbox,
  ) {
    if (!mailbox.isTrash) return null;
    return () => controller.mailboxDashBoardController
        .executeDeleteTrashSubfolders(mailbox.id, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deleteSubfoldersCallback = _buildDeleteSubfoldersCallback(
      context,
      ref,
      mailboxNode.item,
    );
    return Obx(
      () => MailboxItemWidget(
        mailboxNode: mailboxNode,
        mailboxNodeSelected:
            controller.mailboxDashBoardController.selectedMailbox.value,
        isDraggingMailbox:
            controller.mailboxDashBoardController.isDraggingMailbox,
        isHighlighted: isHighlighted,
        onOpenMailboxFolderClick: (mailboxNode) => mailboxNode != null
            ? controller.openMailbox(context, mailboxNode.item)
            : null,
        onExpandFolderActionClick: mailboxNode.hasChildren()
            ? (mailboxNode, itemKey) => controller.toggleMailboxFolder(
                mailboxNode,
                controller.mailboxListScrollController,
                itemKey,
              )
            : null,
        onSelectMailboxFolderClick: controller.selectMailboxNode,
        onLongPressMailboxNodeAction: (mailboxNode) =>
            controller.handleLongPressMailboxNodeAction(
              context,
              mailboxNode.item,
              onDeleteTrashSubfolders: deleteSubfoldersCallback,
            ),
        onDragItemAccepted: controller.handleDragItemAccepted,
        onMenuActionClick: (position, mailboxNode) =>
            controller.openMailboxContextMenuAction(
              context,
              position,
              mailboxNode.item,
              onDeleteTrashSubfolders: deleteSubfoldersCallback,
            ),
        onEmptyMailboxActionCallback: (mailboxNode) =>
            controller.emptyMailboxAction(
              context,
              mailboxNode.item,
              onDeleteTrashSubfolders: deleteSubfoldersCallback,
            ),
      ),
    );
  }
}
