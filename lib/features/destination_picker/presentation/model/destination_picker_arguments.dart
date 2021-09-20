
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class DestinationPickerArguments with EquatableMixin{
  final AccountId accountId;
  final List<EmailId> emailIds;
  final MailboxId currentMailboxId;

  DestinationPickerArguments(this.accountId, this.emailIds, this.currentMailboxId);

  @override
  List<Object?> get props => [accountId, emailIds, currentMailboxId];
}