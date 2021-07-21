import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/jmap_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';

class MailboxDataSourceImpl extends MailboxDataSource {

  final MailboxAPI mailboxAPI;

  MailboxDataSourceImpl(this.mailboxAPI,);

  @override
  Future<List<Mailbox>> getAllMailbox(AccountId accountId, {Properties? properties}) {
    return Future.sync(() async {
      return await mailboxAPI.getAllMailbox(accountId, properties: properties);
    }).catchError((error) {
      throw error;
    });
  }
}