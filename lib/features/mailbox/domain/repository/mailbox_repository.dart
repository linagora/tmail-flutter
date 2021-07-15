import 'package:model/model.dart';

abstract class MailboxRepository {
  Future<List<Mailbox>> getAllMailbox(AccountId accountId, {Properties? properties});
}