import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class MailboxNode with EquatableMixin{
  static PresentationMailbox _root = PresentationMailbox(MailboxId(Id('root')));

  PresentationMailbox item;
  List<MailboxNode>? childrenItems;

  factory MailboxNode.root() => MailboxNode(_root);

  bool hasChildren() => childrenItems?.isNotEmpty ?? false;

  MailboxNode(this.item, {this.childrenItems});

  void addChildNode(MailboxNode node) {
    if (childrenItems == null) {
      childrenItems = [];
    }
    childrenItems?.add(node);
  }

  @override
  List<Object?> get props => [item, childrenItems];
}