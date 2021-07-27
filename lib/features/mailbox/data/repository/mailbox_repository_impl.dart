import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
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