
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

class MailboxCreatorArguments with EquatableMixin{
  final AccountId accountId;
  final MailboxTree personalMailboxTree;
  final MailboxTree defaultMailboxTree;
  final MailboxTree teamMailboxesTree;
  final Session session;

  MailboxCreatorArguments(
    this.accountId, 
    this.defaultMailboxTree, 
    this.personalMailboxTree,
    this.teamMailboxesTree,
    this.session);

  @override
  List<Object?> get props => [
    accountId, 
    defaultMailboxTree, 
    personalMailboxTree,
    teamMailboxesTree,
    session];
}