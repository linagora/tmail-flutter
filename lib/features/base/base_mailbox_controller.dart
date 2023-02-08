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

  final personalMailboxTree = MailboxTree(MailboxNode.root()).obs;
  final defaultMailboxTree = MailboxTree(MailboxNode.root()).obs;
  final teamMailboxesTree =  MailboxTree(MailboxNode.root()).obs;

  List<PresentationMailbox> allMailboxes = <PresentationMailbox>[];

  Future buildTree(
      List<PresentationMailbox> allMailbox,
      {MailboxId? mailboxIdSelected}
  ) async {
    allMailboxes = allMailbox;
    final tupleTree = await _treeBuilder.generateMailboxTreeInUI(
        allMailbox,
        mailboxIdSelected: mailboxIdSelected);
    defaultMailboxTree.firstRebuild = true;
    personalMailboxTree.firstRebuild = true;
    teamMailboxesTree.firstRebuild = true;
    defaultMailboxTree.value = tupleTree.value1;
    personalMailboxTree.value = tupleTree.value2;
    teamMailboxesTree.value = tupleTree.value3;
    allMailboxes = tupleTree.value4;
  }

  Future refreshTree(List<PresentationMailbox> allMailbox) async {
    allMailboxes = allMailbox;
    final tupleTree = await _treeBuilder.generateMailboxTreeInUIAfterRefreshChanges(
      allMailbox, 
      defaultMailboxTree.value, 
      personalMailboxTree.value,
      teamMailboxesTree.value);
    defaultMailboxTree.firstRebuild = true;
    personalMailboxTree.firstRebuild = true;
    teamMailboxesTree.firstRebuild = true;
    defaultMailboxTree.value = tupleTree.value1;
    personalMailboxTree.value = tupleTree.value2;
    teamMailboxesTree.value = tupleTree.value3;
  }

  void toggleMailboxFolder(MailboxNode selectedMailboxNode) {
    final newExpandMode = selectedMailboxNode.expandMode == ExpandMode.COLLAPSE
        ? ExpandMode.EXPAND
        : ExpandMode.COLLAPSE;

    if (defaultMailboxTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) != null) {
      log('toggleMailboxFolder() refresh defaultMailboxTree');
      defaultMailboxTree.refresh();
    }

    if (personalMailboxTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) != null) {
      log('toggleMailboxFolder() refresh folderMailboxTree');
      personalMailboxTree.refresh();
    }

    if (teamMailboxesTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) != null) {
      log('toggleMailboxFolder() refresh teamMailboxesTree');
      teamMailboxesTree.refresh();
    }
  }

  void selectMailboxNode(MailboxNode mailboxNodeSelected) {
    final newSelectMode = mailboxNodeSelected.selectMode == SelectMode.INACTIVE
        ? SelectMode.ACTIVE
        : SelectMode.INACTIVE;

    if (defaultMailboxTree.value.updateSelectedNode(mailboxNodeSelected, newSelectMode) != null) {
      log('selectMailboxNode() refresh defaultMailboxTree');
      defaultMailboxTree.refresh();
    }

    if (personalMailboxTree.value.updateSelectedNode(mailboxNodeSelected, newSelectMode) != null) {
      log('selectMailboxNode() refresh folderMailboxTree');
      personalMailboxTree.refresh();
    }

    if (teamMailboxesTree.value.updateSelectedNode(mailboxNodeSelected, newSelectMode) != null) {
      log('selectMailboxNode() refresh folderMailboxTree');
      teamMailboxesTree.refresh();
    }
  }

  void unAllSelectedMailboxNode() {
    defaultMailboxTree.value.updateNodesUIMode(selectMode: SelectMode.INACTIVE);
    personalMailboxTree.value.updateNodesUIMode(selectMode: SelectMode.INACTIVE);
    teamMailboxesTree.value.updateNodesUIMode(selectMode: SelectMode.INACTIVE);
    defaultMailboxTree.refresh();
    personalMailboxTree.refresh();
    teamMailboxesTree.refresh();
  }

  MailboxNode? findMailboxNodeById(MailboxId mailboxId) {
    final mailboxNode = defaultMailboxTree.value.findNode((node) => node.item.id == mailboxId);
    final mailboxPersonal = personalMailboxTree.value.findNode((node) => node.item.id == mailboxId);
    if (mailboxNode != null) {
      return mailboxNode;
    }
    
    if (mailboxPersonal != null) {
      return mailboxPersonal;
    }
    return teamMailboxesTree.value.findNode((node) => node.item.id == mailboxId);
  }

  String? findNodePath(MailboxId mailboxId) {
    var mailboxNodePath = defaultMailboxTree.value.getNodePath(mailboxId);
    if (mailboxNodePath == null) {
      return personalMailboxTree.value.getNodePath(mailboxId);
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

  bool get defaultMailboxHasChild =>
      defaultMailboxTree.value.root.childrenItems?.isNotEmpty ?? false;

  bool get personalMailboxHasChild =>
      personalMailboxTree.value.root.childrenItems?.isNotEmpty ?? false;
  
  bool get teamMailboxesHasChild {
    return (teamMailboxesTree.value.root.childrenItems?.isNotEmpty ?? false)
      && !teamMailboxesTree.value.root.item.isTeamMailboxes;
  }

  MailboxNode get defaultRootNode => defaultMailboxTree.value.root;

  MailboxNode get personalRootNode => personalMailboxTree.value.root;

  MailboxNode get teamMailboxesRootNode => teamMailboxesTree.value.root;

}
