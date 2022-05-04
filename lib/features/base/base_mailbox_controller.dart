import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:core/utils/app_logger.dart';

abstract class BaseMailboxController extends BaseController {
  final TreeBuilder _treeBuilder;

  BaseMailboxController(this._treeBuilder);

  final folderMailboxTree = MailboxTree(MailboxNode.root()).obs;
  final defaultMailboxTree = MailboxTree(MailboxNode.root()).obs;
  final listMailboxNodeSelected = <MailboxNode>[].obs;
  final listPresentationMailboxSelected = <PresentationMailbox>[].obs;

  List<PresentationMailbox> allMailboxes = <PresentationMailbox>[];

  Future buildTree(List<PresentationMailbox> allMailbox) async {
    allMailboxes = allMailbox;
    final tupleTree = await _treeBuilder.generateMailboxTreeInUI(allMailbox);
    defaultMailboxTree.value = tupleTree.value1;
    folderMailboxTree.value = tupleTree.value2;
  }

  Future refreshTree(List<PresentationMailbox> allMailbox) async {
    allMailboxes = allMailbox;
    final tupleTree = await _treeBuilder.generateMailboxTreeInUIAfterRefreshChanges(
      allMailbox, defaultMailboxTree.value, folderMailboxTree.value);
    defaultMailboxTree.firstRebuild = true;
    folderMailboxTree.firstRebuild = true;
    defaultMailboxTree.value = tupleTree.value1;
    folderMailboxTree.value = tupleTree.value2;
  }

  void toggleMailboxFolder(MailboxNode selectedMailboxNode) {
    final newExpandMode = selectedMailboxNode.expandMode == ExpandMode.COLLAPSE
        ? ExpandMode.EXPAND
        : ExpandMode.COLLAPSE;

    if (defaultMailboxTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) != null) {
      log('toggleMailboxFolder() refresh defaultMailboxTree');
      defaultMailboxTree.refresh();
    }

    if (folderMailboxTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) != null) {
      log('toggleMailboxFolder() refresh folderMailboxTree');
      folderMailboxTree.refresh();
    }
  }

  void selectMailboxNode(MailboxNode mailboxNodeSelected) {
    final newSelectMode = mailboxNodeSelected.selectMode == SelectMode.INACTIVE
        ? SelectMode.ACTIVE
        : SelectMode.INACTIVE;


    if (newSelectMode == SelectMode.INACTIVE) {
      listMailboxNodeSelected.removeWhere((mailboxNode) => mailboxNode.item.id == mailboxNodeSelected.item.id);
    } else {
      listMailboxNodeSelected.add(mailboxNodeSelected);
    }

    if (defaultMailboxTree.value.updateSelectedNode(mailboxNodeSelected, newSelectMode) != null) {
      log('selectMailboxNode() refresh defaultMailboxTree');
      defaultMailboxTree.refresh();
    }

    if (folderMailboxTree.value.updateSelectedNode(mailboxNodeSelected, newSelectMode) != null) {
      log('selectMailboxNode() refresh folderMailboxTree');
      folderMailboxTree.refresh();
    }
  }

  MailboxNode? findMailboxNodeById(MailboxId mailboxId) {
    final mailboxNode = defaultMailboxTree.value.findNode((node) => node.item.id == mailboxId);
    if (mailboxNode != null) {
      return mailboxNode;
    }
    return folderMailboxTree.value.findNode((node) => node.item.id == mailboxId);
  }

  String? findNodePath(MailboxId mailboxId) {
    var mailboxNodePath = defaultMailboxTree.value.getNodePath(mailboxId);
    if (mailboxNodePath == null) {
      return folderMailboxTree.value.getNodePath(mailboxId);
    }
    return mailboxNodePath;
  }

  MailboxNode? findMailboxNodeByRole(Role role) {
    final mailboxNode = defaultMailboxTree.value.findNode((node) => node.item.role == role);
    return mailboxNode;
  }

  List<PresentationMailbox> findMailboxPath(List<PresentationMailbox> mailboxes) {
    return mailboxes.map((presentationMailbox) {
      if (!presentationMailbox.hasParentId()) {
        return presentationMailbox;
      } else {
        final mailboxNodePath = findNodePath(presentationMailbox.id);
        if (mailboxNodePath != null) {
          return presentationMailbox.toPresentationMailboxWithMailboxPath(mailboxNodePath);
        } else {
          return presentationMailbox;
        }
      }
    }).toList();
  }
}
