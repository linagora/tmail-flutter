
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/expand_folder_trigger_scrollable_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/expand_mode_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/bottom_modal_folder_tree_arguments.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class BottomModalFolderTreeListController extends BaseController
    with ExpandFolderTriggerScrollableMixin {
  final personalMailboxTree = MailboxTree(MailboxNode.root()).obs;
  final defaultMailboxTree = MailboxTree(MailboxNode.root()).obs;
  final mailboxIdSelected = Rxn<MailboxId>();

  final ScrollController listFolderScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    BottomModalFolderTreeArguments? arguments = Get.arguments;
    if (arguments != null) {
      personalMailboxTree.value = arguments.personalMailboxTree;
      defaultMailboxTree.value = arguments.defaultMailboxTree;
      mailboxIdSelected.value = arguments.selectedMailbox?.id;
    }
  }

  void selectFolderAction(MailboxNode? mailboxNode) {
    final selectedMailbox = mailboxNode?.item;
    popBack(result: selectedMailbox);
  }

  void toggleFolder(MailboxNode selectedMailboxNode, GlobalKey itemKey) {
    final newExpandMode = selectedMailboxNode.expandMode.toggle();

    if (defaultMailboxTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) != null) {
      defaultMailboxTree.refresh();
      triggerScrollWhenExpandFolder(
        selectedMailboxNode.expandMode,
        itemKey,
        listFolderScrollController,
      );
    }

    if (personalMailboxTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) != null) {
      personalMailboxTree.refresh();
      triggerScrollWhenExpandFolder(
        selectedMailboxNode.expandMode,
        itemKey,
        listFolderScrollController,
      );
    }
  }

  @override
  void onClose() {
    listFolderScrollController.dispose();
    super.onClose();
  }
}