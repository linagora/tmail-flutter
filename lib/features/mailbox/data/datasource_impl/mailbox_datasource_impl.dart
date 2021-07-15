import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/jmap_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/account_id_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/properties_extension.dart';

class MailboxDataSourceImpl extends MailboxDataSource {

  final MailboxAPI mailboxAPI;

  MailboxDataSourceImpl(this.mailboxAPI,);

  @override
  Future<List<Mailbox>> getAllMailbox(AccountId accountId, {Properties? properties}) {
    return Future.sync(() async {
      final listJmapMailbox = await mailboxAPI.getAllMailbox(accountId.toJmapAccountId(), properties: properties?.toJmapProperties());
      return listJmapMailbox.map((mailbox) => mailbox.toMailbox()).toList();
    }).catchError((error) {
      throw error;
    });
  }
}