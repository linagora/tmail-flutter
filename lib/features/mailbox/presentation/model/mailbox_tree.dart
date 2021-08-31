
import 'package:equatable/equatable.dart';

import 'mailbox_node.dart';

class MailboxTree with EquatableMixin {
  MailboxNode root;
  MailboxTree(this.root);

  @override
  List<Object?> get props => [root];
}