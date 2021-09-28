import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

abstract class MailboxRepository {
  Stream<List<Mailbox>> getAllMailbox(AccountId accountId, {Properties? properties});

  Stream<List<Mailbox>> refresh(AccountId accountId, State currentState);
}