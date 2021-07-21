import 'package:built_collection/built_collection.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class MailboxNode {
  static PresentationMailbox _root = PresentationMailbox(MailboxId(Id('root')));

  PresentationMailbox item;
  late BuiltList<MailboxNode> childrenItems;

  factory MailboxNode.root() => MailboxNode(_root);

  MailboxNode(this.item, {List<MailboxNode> child = const []}) {
    this.childrenItems = BuiltList(child);
  }

  MailboxNode? addChild(PresentationMailbox mailbox) {
    if (mailbox.parentId == item.id ||
        (mailbox.parentId == null && item.id == _root.id)) {
      final node = MailboxNode(mailbox);
      _addChildNode(node);
      return node;
    }
    return null;
  }

  void _addChildNode(MailboxNode node) {
    childrenItems = (ListBuilder<MailboxNode>(childrenItems)
        ..add(node))
      .build();
  }
}