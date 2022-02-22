
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class MailboxCreatorArguments with EquatableMixin{
  final AccountId accountId;
  final List<PresentationMailbox> allMailboxes;

  MailboxCreatorArguments(this.accountId, this.allMailboxes);

  @override
  List<Object?> get props => [accountId, allMailboxes];
}