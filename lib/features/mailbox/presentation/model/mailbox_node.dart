import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/mailbox_state.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';

class MailboxNode with EquatableMixin{
  static final PresentationMailbox _root = PresentationMailbox(MailboxId(Id('root')));

  PresentationMailbox item;
  List<MailboxNode>? childrenItems;
  ExpandMode expandMode;
  SelectMode selectMode;
  MailboxState nodeState;

  factory MailboxNode.root() => MailboxNode(_root);

  static PresentationMailbox rootItem() => _root;

  bool hasChildren() => childrenItems?.isNotEmpty ?? false;

  bool hasParents() => item.hasParentId();

  bool get isActivated => nodeState == MailboxState.activated;

  bool get isSelected => selectMode == SelectMode.ACTIVE;

  MailboxNode(
    this.item,
    {
      this.childrenItems,
      this.expandMode = ExpandMode.COLLAPSE,
      this.selectMode = SelectMode.INACTIVE,
      this.nodeState = MailboxState.activated,
    }
  );

  bool get nameNotEmpty => item.name?.name.isNotEmpty == true;

  String get mailboxNameAsString => item.name?.name ?? '';

  void addChildNode(MailboxNode node) {
    childrenItems ??= [];
    childrenItems?.add(node);
  }

  void updateNodeState(MailboxState state) {
    nodeState = state;
  }

  void updateItem(PresentationMailbox newItem) {
    item = newItem;
  }

  List<MailboxNode>? updateNode(MailboxId mailboxId, MailboxNode newNode, {MailboxNode? parent}) {
    List<MailboxNode>? children = parent == null ? childrenItems : parent.childrenItems;
    return children?.map((MailboxNode child) {
      if (child.item.id == mailboxId) {
        return newNode;
      } else {
        if (child.hasChildren()) {
          return child.copyWith(
            children: updateNode(
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

  List<MailboxNode> descendantsAsList(){
    List<MailboxNode> listOfNodes = <MailboxNode>[];
    _appendDescendants(this, listOfNodes);
    return listOfNodes;
  }

  void _appendDescendants(MailboxNode? node, List<MailboxNode> listOfNodes) {
    if (node != null) {
      listOfNodes.add(node);
      List<MailboxNode>? childrenItems = node.childrenItems;
      if (childrenItems != null) {
        for (var child in childrenItems) {
          _appendDescendants(child, listOfNodes);
        }
      }
    }
  }

  List<MailboxNode>? toggleSelectNode(MailboxNode selectedMailboxMode, {MailboxNode? parent}) {
    List<MailboxNode>? children = parent == null ? childrenItems : parent.childrenItems;
    return children?.map((MailboxNode child) {
      if (child.item.id == selectedMailboxMode.item.id) {
        return child.toggleSelectMailboxNode();
      } else {
        if (child.hasChildren()) {
          return child.copyWith(children: toggleSelectNode(selectedMailboxMode, parent: child));
        }
        return child;
      }
    }).toList();
  }

  List<MailboxNode>? toSelectedNode({required SelectMode selectMode, ExpandMode? newExpandMode, MailboxNode? parent}) {
    List<MailboxNode>? children = parent == null ? childrenItems : parent.childrenItems;
    return children?.map((MailboxNode child) {
      if (child.hasChildren()) {
        return child.copyWith(
            children: toSelectedNode(selectMode: selectMode, newExpandMode: newExpandMode, parent: child),
            newSelectMode: selectMode,
            newExpandMode: newExpandMode);
      }
      return child.toSelectedMailboxNode(selectMode: selectMode, newExpandMode: newExpandMode);
    }).toList();
  }

  @override
  List<Object?> get props => [item, childrenItems, expandMode, selectMode];
}

extension MailboxNodeExtension on MailboxNode {
  MailboxNode copyWith({
    SelectMode? newSelectMode,
    ExpandMode? newExpandMode,
    MailboxState? newNodeState,
    PresentationMailbox? newItem,
    List<MailboxNode>? children
  }) {
    return MailboxNode(
      newItem ?? item,
      childrenItems: children ?? childrenItems,
      expandMode: newExpandMode ?? expandMode,
      selectMode: newSelectMode ?? selectMode,
      nodeState: newNodeState ?? nodeState,
    );
  }

  MailboxNode toggleSelectMailboxNode() {
    return MailboxNode(
        item,
        childrenItems: childrenItems,
        expandMode: expandMode,
        selectMode: selectMode == SelectMode.INACTIVE ? SelectMode.ACTIVE : SelectMode.INACTIVE,
        nodeState: nodeState,
    );
  }

  MailboxNode toSelectedMailboxNode({required SelectMode selectMode, ExpandMode? newExpandMode}) {
    return MailboxNode(
        item,
        childrenItems: childrenItems,
        expandMode: newExpandMode ?? expandMode,
        selectMode: selectMode,
        nodeState: nodeState,
    );
  }

  int compareTo(MailboxNode other) {
    if (item.sortOrder == null) {
      return -1;
    }

    if (other.item.sortOrder == null) {
      return 1;
    }

    return item.sortOrder!.value.value.compareTo(other.item.sortOrder!.value.value);
  }
}
