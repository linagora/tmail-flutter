import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart' as JmapMailbox;
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/jmap_mailbox_right_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/jmap_mailbox_properties_extension.dart';

extension JmapMailboxExtension on JmapMailbox.Mailbox {
  Mailbox toMailbox() {
    return Mailbox(
      id.toMailboxId(),
      name?.toMailboxName(),
      parentId?.toMailboxId(),
      role?.toMailboxRole(),
      sortOrder?.toSortOrder(),
      totalEmails?.toTotalEmails(),
      unreadEmails?.toUnreadEmails(),
      totalThreads?.toTotalThreads(),
      unreadThreads?.toUnreadThreads(),
      myRights?.toMailboxRights(),
      isSubscribed?.toIsSubscribed()
    );
  }
}