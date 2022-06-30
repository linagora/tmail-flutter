
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';

class MailboxMarkAsReadArguments with EquatableMixin {

  final AccountId accountId;
  final MailboxId mailboxId;
  final ThreadAPI threadAPI;
  final EmailAPI emailAPI;

  MailboxMarkAsReadArguments(
    this.threadAPI,
    this.emailAPI,
    this.accountId,
    this.mailboxId);

  @override
  List<Object?> get props => [accountId, mailboxId];
}