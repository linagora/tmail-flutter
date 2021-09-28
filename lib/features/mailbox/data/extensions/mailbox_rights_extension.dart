import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_rights.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_rights_cache.dart';

extension MailboxRightsExtension on MailboxRights {
  MailboxRightsCache toMailboxRightsCache() {
    return MailboxRightsCache(
      mayReadItems,
      mayAddItems,
      mayRemoveItems,
      maySetSeen,
      maySetKeywords,
      mayCreateChild,
      mayRename,
      mayDelete,
      maySubmit
    );
  }
}