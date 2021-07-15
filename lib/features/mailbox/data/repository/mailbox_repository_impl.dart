import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class MailboxRepositoryImpl extends MailboxRepository {

  final MailboxDataSource mailboxDataSource;

  MailboxRepositoryImpl(this.mailboxDataSource);

  @override
  Future<List<Mailbox>> getAllMailbox(AccountId accountId, {Properties? properties}) {
    return mailboxDataSource.getAllMailbox(accountId, properties: properties);
  }
}