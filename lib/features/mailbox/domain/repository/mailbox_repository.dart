import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

abstract class MailboxRepository {
  Future<List<Mailbox>> getAllMailbox(AccountId accountId, {Properties? properties});
}