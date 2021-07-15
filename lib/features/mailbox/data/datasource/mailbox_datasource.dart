import 'package:model/model.dart';

abstract class MailboxDataSource {
  Future<List<Mailbox>> getAllMailbox(AccountId accountId, {Properties? properties});
}