import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart' as JmapMailbox;
import 'package:model/core/id.dart';
import 'package:model/model.dart';

extension JmapMailboxIdExtension on JmapMailbox.MailboxId {
  MailboxId toMailboxId() => MailboxId(Id(id.value));
}

extension JmapMailboxNameExtension on JmapMailbox.MailboxName {
  MailboxName toMailboxName() => MailboxName(name);
}

extension JmapMailboxRoleExtension on JmapMailbox.Role {
  Role toMailboxRole() => Role(value);
}

extension JmapMailboxSortOrderExtension on JmapMailbox.SortOrder {
  SortOrder toSortOrder() => SortOrder(sortValue: value.value.toInt());
}

extension JmapMailboxTotalEmailsExtension on JmapMailbox.TotalEmails {
  TotalEmails toTotalEmails() => TotalEmails(UnsignedInt(value.value));
}

extension JmapMailboxUnreadEmailsExtension on JmapMailbox.UnreadEmails {
  UnreadEmails toUnreadEmails() => UnreadEmails(UnsignedInt(value.value));
}

extension JmapMailboxTotalThreadsExtension on JmapMailbox.TotalThreads {
  TotalThreads toTotalThreads() => TotalThreads(UnsignedInt(value.value));
}

extension JmapMailboxUnreadThreadsExtension on JmapMailbox.UnreadThreads {
  UnreadThreads toUnreadThreads() => UnreadThreads(UnsignedInt(value.value));
}

extension JmapMailboxIsSubscribedExtension on JmapMailbox.IsSubscribed {
  IsSubscribed toIsSubscribed() => IsSubscribed(value);
}