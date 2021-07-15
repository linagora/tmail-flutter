import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_rights.dart' as JmapMailboxRights;
import 'package:model/model.dart';

extension JmapMailboxRightsExtension on JmapMailboxRights.MailboxRights {
  MailboxRights toMailboxRights() => MailboxRights(
    this.mayReadItems,
    this.mayAddItems,
    this.mayRemoveItems,
    this.maySetSeen,
    this.maySetKeywords,
    this.mayCreateChild,
    this.mayRename,
    this.mayDelete,
    this.maySubmit);
}