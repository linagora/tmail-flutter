import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_rights.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_rights_cache.dart';

extension MailboxRightsCacheExtension on MailboxRightsCache {
  MailboxRights toMailboxRights() {
    return MailboxRights(
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