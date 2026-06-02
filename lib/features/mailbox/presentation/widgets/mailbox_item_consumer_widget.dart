import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_mailbox_action_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';

class MailboxItemConsumerWidget extends StatelessWidget {
  final MailboxNode mailboxNode;
  final MailboxController controller;
  final bool isHighlighted;

  const MailboxItemConsumerWidget({
    super.key,
    required this.mailboxNode,
    required this.controller,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
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
            ),
        onDragItemAccepted: controller.handleDragItemAccepted,
        onMenuActionClick: (position, mailboxNode) =>
            controller.openMailboxContextMenuAction(
              context,
              position,
              mailboxNode.item,
            ),
        onEmptyMailboxActionCallback: (mailboxNode) {
          if (mailboxNode.item.isTrash) {
            controller.emptyTrashAction(
              context,
              mailboxNode.item,
              controller.mailboxDashBoardController,
            );
          } else {
            controller.emptyMailboxAction(context, mailboxNode.item);
          }
        },
      ),
    );
  }
}
