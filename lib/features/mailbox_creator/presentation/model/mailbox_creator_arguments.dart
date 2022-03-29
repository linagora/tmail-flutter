
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

class MailboxCreatorArguments with EquatableMixin{
  final AccountId accountId;
  final MailboxTree folderMailboxTree;
  final MailboxTree defaultMailboxTree;

  MailboxCreatorArguments(this.accountId, this.defaultMailboxTree, this.folderMailboxTree);

  @override
  List<Object?> get props => [accountId, defaultMailboxTree, folderMailboxTree];
}