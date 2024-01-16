
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/extensions/mailbox_id_extension.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';

extension ListMailboxExtension on List<Mailbox> {
  Map<String, MailboxCache> toMapCache(AccountId accountId, UserName userName) {
    return {
      for (var mailbox in this)
        TupleKey(accountId.asString, userName.value, mailbox.id!.asString).encodeKey : mailbox.toMailboxCache()
    };
  }
}