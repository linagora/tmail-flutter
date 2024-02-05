import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_rights.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

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

  static final mailboxA = Mailbox(id: MailboxId(Id('A')));
  static final mailboxB = Mailbox(id: MailboxId(Id('B')));
  static final mailboxC = Mailbox(id: MailboxId(Id('C')));
  static final mailboxD = Mailbox(id: MailboxId(Id('D')));

  static final selectedFolderToDelete = Mailbox(
    id: MailboxId(Id('folderToDelete')),
    name: MailboxName('folderToDelete'),
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
      true
    ),
    isSubscribed: IsSubscribed(true)
  );

  static final selectedFolderToDelete_1 = Mailbox(
    id: MailboxId(Id('folderToDelete_1')),
    name: MailboxName('folderToDelete_1'),
    parentId: MailboxId(Id("folderToDelete")),
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
      true
    ),
    isSubscribed: IsSubscribed(false)
  );

  static final selectedFolderToDelete_2 = Mailbox(
    id: MailboxId(Id('folderToDelete_2')),
    name: MailboxName('folderToDelete_2'),
    parentId: MailboxId(Id("folderToDelete_1")),
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
      true
    ),
    isSubscribed: IsSubscribed(false)
  );

  static final selectedFolderToDelete_3 = Mailbox(
    id: MailboxId(Id('folderToDelete_3')),
    name: MailboxName('folderToDelete_3'),
    parentId: MailboxId(Id("folderToDelete")),
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
      true
    ),
    isSubscribed: IsSubscribed(true)
  );

  static final selectedFolderToDelete_4 = Mailbox(
    id: MailboxId(Id('folderToDelete_4')),
    name: MailboxName('folderToDelete_4'),
    parentId: MailboxId(Id("folderToDelete_3")),
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
      true
    ),
    isSubscribed: IsSubscribed(false)
  );

  static final selectedFolderToDelete_5 = Mailbox(
    id: MailboxId(Id('folderToDelete_5')),
    name: MailboxName('folderToDelete_5'),
    parentId: MailboxId(Id("folderToDelete_3")),
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
      true
    ),
    isSubscribed: IsSubscribed(false)
  );

  static final selectedFolderToDelete_6 = Mailbox(
    id: MailboxId(Id('folderToDelete_6')),
    name: MailboxName('folderToDelete_6'),
    parentId: MailboxId(Id("folderToDelete_5")),
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
      true
    ),
    isSubscribed: IsSubscribed(false)
  );

  static final selectedFolderToDelete_7 = Mailbox(
    id: MailboxId(Id('folderToDelete_7')),
    name: MailboxName('folderToDelete_7'),
    parentId: MailboxId(Id("folderToDelete_6")),
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
      true
    ),
    isSubscribed: IsSubscribed(false)
  );

  static final selectedFolderToDelete_8 = Mailbox(
    id: MailboxId(Id('folderToDelete_8')),
    name: MailboxName('folderToDelete_8'),
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
      true
    ),
    isSubscribed: IsSubscribed(true)
  );

  static final selectedFolderToDelete_9 = Mailbox(
    id: MailboxId(Id('folderToDelete_9')),
    name: MailboxName('folderToDelete_9'),
    parentId: MailboxId(Id("folderToDelete_8")),
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
      true
    ),
    isSubscribed: IsSubscribed(false)
  );

  static final selectedFolderToDelete_10 = Mailbox(
    id: MailboxId(Id('folderToDelete_10')),
    name: MailboxName('folderToDelete_10'),
    parentId: MailboxId(Id("folderToDelete_8")),
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
      true
    ),
    isSubscribed: IsSubscribed(false)
  );

  static final listMailboxIdToDelete = [
    MailboxId(Id('folderToDelete_7')),
    MailboxId(Id('folderToDelete_6')),
    MailboxId(Id('folderToDelete_5')),
    MailboxId(Id('folderToDelete_4')),
    MailboxId(Id('folderToDelete_3')),
    MailboxId(Id('folderToDelete_2')),
    MailboxId(Id('folderToDelete_1')),
    MailboxId(Id('folderToDelete')),
    MailboxId(Id('folderToDelete_10')),
    MailboxId(Id('folderToDelete_9')),
    MailboxId(Id('folderToDelete_8'))
  ];

  static final listDescendantMailboxForSelectedFolder = <MailboxId>[
    MailboxId(Id('folderToDelete_7')),
    MailboxId(Id('folderToDelete_6')),
    MailboxId(Id('folderToDelete_5')),
    MailboxId(Id('folderToDelete_4')),
    MailboxId(Id('folderToDelete_3')),
    MailboxId(Id('folderToDelete_2')),
    MailboxId(Id('folderToDelete_1')),
    MailboxId(Id('folderToDelete')),
  ];

  static final listDescendantMailboxForSelectedFolder2 = <MailboxId>[
    MailboxId(Id('folderToDelete_10')),
    MailboxId(Id('folderToDelete_9')),
    MailboxId(Id('folderToDelete_8'))
  ];

  static final listMailboxToDelete = <PresentationMailbox>[
    selectedFolderToDelete.toPresentationMailbox(),
    selectedFolderToDelete_8.toPresentationMailbox()
  ];
}