import 'dart:math';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/list/tree_view.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/folder_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/widgets/bottom_modal/bottom_modal_folder_tree_list_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class BottomModalFolderTreeListWidget extends GetWidget<BottomModalFolderTreeListController> {

  const BottomModalFolderTreeListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget = Container(
      constraints: BoxConstraints(
        maxHeight: min(
          controller.responsiveUtils.getSizeScreenHeight(context) - 32,
          469,
        ),
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        controller: controller.listFolderScrollController,
        padding: const EdgeInsetsDirectional.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => FolderItemWidget(
              folderName: AppLocalizations.of(context).personalFolders,
              imagePaths: controller.imagePaths,
              isSelected: controller.mailboxIdSelected.value == null,
              iconColor: AppColor.gray424244.withValues(alpha: 0.72),
              iconSelected: controller.imagePaths.icChecked,
              textStyle: ThemeUtils.textStyleInter400.copyWith(
                color: AppColor.gray424244.withValues(alpha: 0.9),
                fontSize: 16,
                height: 21.01 / 16,
                letterSpacing: -0.15,
              ),
              onTapAction: () =>
                controller.selectFolderAction(MailboxNode.root()),
            )),
            Obx(() {
              final defaultTree = controller.defaultMailboxTree.value;
              if (defaultTree.root.hasChildren()) {
                return _buildFolderTree(
                  mailboxTree: defaultTree,
                  mailboxIdSelected: controller.mailboxIdSelected.value,
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
            Obx(() {
              final personalTree = controller.personalMailboxTree.value;
              if (personalTree.root.hasChildren()) {
                return _buildFolderTree(
                  mailboxTree: personalTree,
                  mailboxIdSelected: controller.mailboxIdSelected.value,
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );

    if (PlatformInfo.isMobile) {
      return SafeArea(child: bodyWidget);
    } else {
      return bodyWidget;
    }
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
              iconColor: AppColor.gray424244.withValues(alpha: 0.72),
              textStyle: ThemeUtils.textStyleInter400.copyWith(
                color: AppColor.gray424244.withValues(alpha: 0.9),
                fontSize: 16,
                height: 21.01 / 16,
                letterSpacing: -0.15,
              ),
              itemHeight: 48,
              iconSelected: controller.imagePaths.icChecked,
              onOpenMailboxFolderClick: controller.selectFolderAction,
              onExpandFolderActionClick: controller.toggleFolder,
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
            iconColor: AppColor.gray424244.withValues(alpha: 0.72),
            textStyle: ThemeUtils.textStyleInter400.copyWith(
              color: AppColor.gray424244.withValues(alpha: 0.9),
              fontSize: 16,
              height: 21.01 / 16,
              letterSpacing: -0.15,
            ),
            itemHeight: 48,
            iconSelected: controller.imagePaths.icChecked,
            onOpenMailboxFolderClick: controller.selectFolderAction,
            onExpandFolderActionClick: controller.toggleFolder,
          );
        }
      },
    ).toList() ?? [];
  }
}
