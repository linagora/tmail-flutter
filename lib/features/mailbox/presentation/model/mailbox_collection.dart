import 'package:equatable/equatable.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

class MailboxCollection with EquatableMixin {
  final List<PresentationMailbox> allMailboxes;
  final MailboxTree defaultTree;
  final MailboxTree personalTree;
  final MailboxTree teamMailboxTree;

  const MailboxCollection({
    required this.allMailboxes,
    required this.defaultTree,
    required this.personalTree,
    required this.teamMailboxTree,
  });

  factory MailboxCollection.empty() => MailboxCollection(
    allMailboxes: const [],
    defaultTree: MailboxTree(MailboxNode.root()),
    personalTree: MailboxTree(MailboxNode.root()),
    teamMailboxTree: MailboxTree(MailboxNode.root()),
  );

  MailboxCollection copyWith({
    List<PresentationMailbox>? allMailboxes,
    MailboxTree? defaultTree,
    MailboxTree? personalTree,
    MailboxTree? teamMailboxTree,
  }) {
    return MailboxCollection(
      allMailboxes: allMailboxes ?? this.allMailboxes,
      defaultTree: defaultTree ?? this.defaultTree,
      personalTree: personalTree ?? this.personalTree,
      teamMailboxTree: teamMailboxTree ?? this.teamMailboxTree,
    );
  }

  @override
  List<Object?> get props => [
        allMailboxes,
        defaultTree,
        personalTree,
        teamMailboxTree,
      ];
}
