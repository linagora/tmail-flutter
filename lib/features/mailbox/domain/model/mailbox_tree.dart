import 'package:core/core.dart';
import 'package:model/model.dart';

class MailboxTree extends TreeNode<PresentationMailbox> {

  final ExpandMode expandMode;

  MailboxTree(
    PresentationMailbox item,
    List<MailboxTree> childrenItems,
    {
      this.expandMode = ExpandMode.COLLAPSE
    }
  ) : super(item, childrenItems);

  bool isExpand() => expandMode == ExpandMode.EXPAND;

  bool isParent() => childrenItems.isNotEmpty;

  bool hasParentId() => item.hasParentId();

  @override
  List<Object?> get props => [item, childrenItems];
}

extension MailboxTreeExtension on MailboxTree {
  MailboxTree setExpandMailboxTree({required ExpandMode expandMode}) {
    return MailboxTree(
      item,
      childrenItems as List<MailboxTree>,
      expandMode: expandMode
    );
  }
}