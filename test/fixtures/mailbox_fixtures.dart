import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_rights.dart';

class MailboxFixtures {
  static final inboxMailbox = Mailbox(
      id: MailboxId(Id('1')),
      name: MailboxName('Inbox'),
      parentId: null,
      role: Role('inbox'),
      sortOrder: SortOrder(sortValue: 10),
      totalEmails: TotalEmails(UnsignedInt(2758)),
      unreadEmails: UnreadEmails(UnsignedInt(34)),
      totalThreads: TotalThreads(UnsignedInt(2758)),
      unreadThreads: UnreadThreads(UnsignedInt(34)),
      myRights: MailboxRights(
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true),
      isSubscribed: IsSubscribed(true)
  );

  static final sentMailbox = Mailbox(
      id: MailboxId(Id('2')),
      name: MailboxName('Sent'),
      parentId: null,
      role: Role('sent'),
      sortOrder: SortOrder(sortValue: 3),
      totalEmails: TotalEmails(UnsignedInt(123)),
      unreadEmails: UnreadEmails(UnsignedInt(12)),
      totalThreads: TotalThreads(UnsignedInt(123)),
      unreadThreads: UnreadThreads(UnsignedInt(12)),
      myRights: MailboxRights(
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true),
      isSubscribed: IsSubscribed(true)
  );

  static final folder1 = Mailbox(
      id: MailboxId(Id('b1')),
      name: MailboxName('folder 1'),
      parentId: null,
      role: null,
      sortOrder: SortOrder(sortValue: 1000),
      totalEmails: TotalEmails(UnsignedInt(123)),
      unreadEmails: UnreadEmails(UnsignedInt(12)),
      totalThreads: TotalThreads(UnsignedInt(123)),
      unreadThreads: UnreadThreads(UnsignedInt(12)),
      myRights: MailboxRights(
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true),
      isSubscribed: IsSubscribed(true)
  );

  static final folder1_1 = Mailbox(
      id: MailboxId(Id('b11')),
      name: MailboxName('folder 1_1'),
      parentId: MailboxId(Id("b1")),
      role: null,
      sortOrder: SortOrder(sortValue: 1000),
      totalEmails: TotalEmails(UnsignedInt(123)),
      unreadEmails: UnreadEmails(UnsignedInt(12)),
      totalThreads: TotalThreads(UnsignedInt(123)),
      unreadThreads: UnreadThreads(UnsignedInt(12)),
      myRights: MailboxRights(
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true),
      isSubscribed: IsSubscribed(true)
  );
}