
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_icon_widget.dart';

class LeadingMailboxItemWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final MailboxNode mailboxNode;
  final SelectMode selectionMode;
  final OnSelectMailboxNodeAction? onSelectMailboxFolderClick;

  const LeadingMailboxItemWidget({
    super.key,
    required this.imagePaths,
    required this.mailboxNode,
    this.selectionMode = SelectMode.INACTIVE,
    this.onSelectMailboxFolderClick,
  });

  @override
  Widget build(BuildContext context) {
    return MailboxIconWidget(
      imagePaths: imagePaths,
      mailboxNode: mailboxNode,
      selectionMode: selectionMode,
      onSelectMailboxFolderClick: onSelectMailboxFolderClick
    );
  }
}