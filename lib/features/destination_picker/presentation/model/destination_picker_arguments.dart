
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class DestinationPickerArguments with EquatableMixin{
  final AccountId accountId;
  final List<EmailId> emailIds;
  final PresentationMailbox currentMailbox;

  DestinationPickerArguments(this.accountId, this.emailIds, this.currentMailbox);

  @override
  List<Object?> get props => [accountId, emailIds, currentMailbox];
}