
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:model/extensions/identity_id_extension.dart';
import 'package:model/extensions/mailbox_id_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_email_hive_cache.dart';

extension SendingEmailExtension on SendingEmail {
  SendingEmailHiveCache toHiveCache() {
    return SendingEmailHiveCache(
      sendingId,
      email.asString(),
      emailActionType.name,
      createTime,
      sentMailboxId?.asString,
      emailIdDestroyed?.asString,
      emailIdAnsweredOrForwarded?.asString,
      identityId?.asString,
      mailboxNameRequest?.name,
      creationIdRequest?.value
    );
  }
}