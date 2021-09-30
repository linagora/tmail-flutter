import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_rights.dart';

class MailboxFixtures {
  static final inboxMailbox = Mailbox(
      MailboxId(Id('1')),
      MailboxName('Inbox'),
      null,
      Role('inbox'),
      SortOrder(sortValue: 10),
      TotalEmails(UnsignedInt(2758)),
      UnreadEmails(UnsignedInt(34)),
      TotalThreads(UnsignedInt(2758)),
      UnreadThreads(UnsignedInt(34)),
      MailboxRights(
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true),
      IsSubscribed(true)
  );

  static final sentMailbox = Mailbox(
      MailboxId(Id('2')),
      MailboxName('Sent'),
      null,
      Role('sent'),
      SortOrder(sortValue: 3),
      TotalEmails(UnsignedInt(123)),
      UnreadEmails(UnsignedInt(12)),
      TotalThreads(UnsignedInt(123)),
      UnreadThreads(UnsignedInt(12)),
      MailboxRights(
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true),
      IsSubscribed(true)
  );

  static final folder1 = Mailbox(
      MailboxId(Id('b1')),
      MailboxName('folder 1'),
      null,
      null,
      SortOrder(sortValue: 1000),
      TotalEmails(UnsignedInt(123)),
      UnreadEmails(UnsignedInt(12)),
      TotalThreads(UnsignedInt(123)),
      UnreadThreads(UnsignedInt(12)),
      MailboxRights(
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true),
      IsSubscribed(true)
  );

  static final folder1_1 = Mailbox(
      MailboxId(Id('b11')),
      MailboxName('folder 1_1'),
      MailboxId(Id("b1")),
      null,
      SortOrder(sortValue: 1000),
      TotalEmails(UnsignedInt(123)),
      UnreadEmails(UnsignedInt(12)),
      TotalThreads(UnsignedInt(123)),
      UnreadThreads(UnsignedInt(12)),
      MailboxRights(
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true),
      IsSubscribed(true)
  );
}