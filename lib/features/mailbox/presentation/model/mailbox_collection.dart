import 'package:equatable/equatable.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

class MailboxCollection with EquatableMixin {
  final List<PresentationMailbox> allMailboxes;
  final MailboxTree defaultTree;
  final MailboxTree personalTree;
  final MailboxTree teamTree;

  const MailboxCollection({
    required this.allMailboxes,
    required this.defaultTree,
    required this.personalTree,
    required this.teamTree,
  });

  MailboxCollection copyWith({
    List<PresentationMailbox>? allMailboxes,
    MailboxTree? defaultTree,
    MailboxTree? personalTree,
    MailboxTree? teamTree,
  }) {
    return MailboxCollection(
      allMailboxes: allMailboxes ?? this.allMailboxes,
      defaultTree: defaultTree ?? this.defaultTree,
      personalTree: personalTree ?? this.personalTree,
      teamTree: teamTree ?? this.teamTree,
    );
  }

  @override
  List<Object?> get props => [
        allMailboxes,
        defaultTree,
        personalTree,
        teamTree,
      ];
}
