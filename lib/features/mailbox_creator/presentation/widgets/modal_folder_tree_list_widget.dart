import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/list/tree_view.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/folder_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ModalFolderTreeListWidget extends StatelessWidget {

  final MailboxTree defaultTree;
  final MailboxTree personalTree;
  final ScrollController listScrollController;
  final ImagePaths imagePaths;
  final OnClickOpenMailboxNodeAction onSelectFolderAction;
  final OnClickExpandMailboxNodeAction onToggleFolderAction;
  final MailboxId? mailboxIdSelected;

  const ModalFolderTreeListWidget({
    super.key,
    required this.defaultTree,
    required this.personalTree,
    required this.listScrollController,
    required this.imagePaths,
    required this.onSelectFolderAction,
    required this.onToggleFolderAction,
    this.mailboxIdSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      controller: listScrollController,
      padding: const EdgeInsetsDirectional.only(end: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FolderItemWidget(
            folderName: AppLocalizations.of(context).personalFolders,
            imagePaths: imagePaths,
            isSelected: mailboxIdSelected == null,
            onTapAction: () => onSelectFolderAction(null),
          ),
          if (defaultTree.root.hasChildren())
            _buildFolderTree(
              mailboxTree: defaultTree,
              mailboxIdSelected: mailboxIdSelected,
            ),
          if (personalTree.root.hasChildren())
            _buildFolderTree(
              mailboxTree: personalTree,
              mailboxIdSelected: mailboxIdSelected,
            ),
        ],
      ),
    );
  }

  Widget _buildFolderTree({
    required MailboxTree mailboxTree,
    MailboxId? mailboxIdSelected,
  }) {
    return TreeView(
      children: _buildListChildTileWidget(
        parentNode: mailboxTree.root,
        mailboxIdSelected: mailboxIdSelected,
      ),
    );
  }

  List<Widget> _buildListChildTileWidget({
    required MailboxNode parentNode,
    MailboxId? mailboxIdSelected,
  }) {
    return parentNode.childrenItems?.map(
      (mailboxNode) {
        if (mailboxNode.hasChildren()) {
          return TreeViewChild(
            isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
            paddingChild: const EdgeInsetsDirectional.only(start: 14),
            parent: MailboxItemWidget(
              mailboxNode: mailboxNode,
              mailboxIdAlreadySelected: mailboxIdSelected,
              mailboxDisplayed: MailboxDisplayed.modalFolder,
              hoverColor: AppColor.blue100,
              onOpenMailboxFolderClick: onSelectFolderAction,
              onExpandFolderActionClick: onToggleFolderAction,
            ),
            children: _buildListChildTileWidget(
              parentNode: mailboxNode,
              mailboxIdSelected: mailboxIdSelected,
            ),
          ).build();
        } else {
          return MailboxItemWidget(
            mailboxNode: mailboxNode,
            mailboxDisplayed: MailboxDisplayed.modalFolder,
            mailboxIdAlreadySelected: mailboxIdSelected,
            hoverColor: AppColor.blue100,
            onOpenMailboxFolderClick: onSelectFolderAction,
            onExpandFolderActionClick: onToggleFolderAction,
          );
        }
      },
    ).toList() ?? [];
  }
}
