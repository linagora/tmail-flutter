
import 'package:equatable/equatable.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

class BottomModalFolderTreeArguments with EquatableMixin {
  final MailboxTree personalMailboxTree;
  final MailboxTree defaultMailboxTree;
  final PresentationMailbox? selectedMailbox;

  BottomModalFolderTreeArguments(
    this.defaultMailboxTree,
    this.personalMailboxTree,
    this.selectedMailbox,
  );

  @override
  List<Object?> get props => [
    defaultMailboxTree,
    personalMailboxTree,
    selectedMailbox,
  ];
}