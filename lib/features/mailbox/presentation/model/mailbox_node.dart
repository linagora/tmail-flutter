import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

class MailboxNode with EquatableMixin{
  static PresentationMailbox _root = PresentationMailbox(MailboxId(Id('root')));

  PresentationMailbox item;
  List<MailboxNode>? childrenItems;
  ExpandMode expandMode;
  SelectMode selectMode;

  factory MailboxNode.root() => MailboxNode(_root);

  static PresentationMailbox rootItem() => _root;

  bool hasChildren() => childrenItems?.isNotEmpty ?? false;

  MailboxNode(
    this.item,
    {
      this.childrenItems,
      this.expandMode = ExpandMode.COLLAPSE,
      this.selectMode = SelectMode.INACTIVE
    }
  );

  void addChildNode(MailboxNode node) {
    if (childrenItems == null) {
      childrenItems = [];
    }
    childrenItems?.add(node);
  }

  String getPathMailboxNode(MailboxTree mailboxTree, List<PresentationMailbox> defaultMailboxList) {
    String path = '${item.name?.name}';

    var parentId = item.parentId;

    while(parentId != null) {
      var parent = mailboxTree.findNode(parentId);
      if (parent == null) {
        try {
          final parentItem = defaultMailboxList.firstWhere((mailbox) => mailbox.id == parentId);
          parent = MailboxNode(parentItem);
        } catch(e) {}
      }

      if (parent != null) {
        path = '${parent.item.name?.name}/$path';
        parentId = parent.item.parentId;
      } else {
        break;
      }
    }

    return path;
  }

  List<MailboxNode>? updateNode(MailboxId mailboxId, MailboxNode newNode, {MailboxNode? parent}) {
    List<MailboxNode>? _children = parent == null ? this.childrenItems : parent.childrenItems;
    return _children?.map((MailboxNode child) {
      if (child.item.id == mailboxId) {
        return newNode;
      } else {
        if (child.hasChildren()) {
          return child.copyWith(
            mailboxNodes: updateNode(
              mailboxId,
              newNode,
              parent: child,
            ),
          );
        }
        return child;
      }
    }).toList();
  }

  List<MailboxNode>? toggleSelectNode(MailboxNode selectedMailboxMode, {MailboxNode? parent}) {
    List<MailboxNode>? _children = parent == null ? this.childrenItems : parent.childrenItems;
    return _children?.map((MailboxNode child) {
      if (child.item.id == selectedMailboxMode.item.id) {
        return child.toggleSelectMailboxNode();
      } else {
        if (child.hasChildren()) {
          return child.copyWith(mailboxNodes: toggleSelectNode(selectedMailboxMode, parent: child));
        }
        return child;
      }
    }).toList();
  }

  List<MailboxNode>? toSelectedNode({required SelectMode selectMode, ExpandMode? newExpandMode, MailboxNode? parent}) {
    List<MailboxNode>? _children = parent == null ? this.childrenItems : parent.childrenItems;
    return _children?.map((MailboxNode child) {
      if (child.hasChildren()) {
        return child.copyWith(
            mailboxNodes: toSelectedNode(selectMode: selectMode, newExpandMode: newExpandMode, parent: child),
            newSelectMode: selectMode,
            newExpandMode: newExpandMode);
      }
      return child.toSelectedMailboxNode(selectMode: selectMode, newExpandMode: newExpandMode);
    }).toList();
  }

  @override
  List<Object?> get props => [item, childrenItems];
}

extension MailboxNodeExtension on MailboxNode {
  MailboxNode copyWith({
    SelectMode? newSelectMode,
    ExpandMode? newExpandMode,
    List<MailboxNode>? mailboxNodes
  }) {
    return MailboxNode(
      item,
      childrenItems: mailboxNodes ?? childrenItems,
      expandMode: newExpandMode ?? expandMode,
      selectMode: newSelectMode ?? selectMode,
    );
  }

  MailboxNode toggleSelectMailboxNode() {
    return MailboxNode(
        item,
        childrenItems: childrenItems,
        expandMode: expandMode,
        selectMode: selectMode == SelectMode.INACTIVE ? SelectMode.ACTIVE : SelectMode.INACTIVE,
    );
  }

    MailboxNode toSelectedMailboxNode({required SelectMode selectMode, ExpandMode? newExpandMode}) {
      return MailboxNode(
          item,
          childrenItems: childrenItems,
          expandMode: newExpandMode ?? expandMode,
          selectMode: selectMode,
      );
  }
}
