import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class MailboxNode with EquatableMixin{
  static PresentationMailbox _root = PresentationMailbox(MailboxId(Id('root')));

  PresentationMailbox item;
  late BuiltList<MailboxNode> childrenItems;

  factory MailboxNode.root() => MailboxNode(_root);

  bool hasChildren() => childrenItems.isNotEmpty;

  MailboxNode(this.item, {List<MailboxNode> child = const []}) {
    this.childrenItems = BuiltList(child);
  }

  MailboxNode? addChild(PresentationMailbox mailbox) {
    if (_validateChild(mailbox)) {
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

  bool _validateChild(PresentationMailbox mailbox) {
    if (mailbox.parentId == item.id) {
      return true;
    }
    if (item == _root) {
      return true;
    }
    return false;
  }

  @override
  List<Object?> get props => [item, childrenItems];
}