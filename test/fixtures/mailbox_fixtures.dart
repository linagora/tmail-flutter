import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_rights.dart';
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

  static final actionRequiredPresentationMailbox =
      PresentationMailbox.actionRequiredFolder;

  static final currentState = State('2c9f1b12-b35a-43e6-9af2-0106fb53a943');

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

  static final listMailboxIdsToDelete = <MailboxId>[
    selectedFolderToDelete.id!,
    selectedFolderToDelete_8.id!,
  ];

  // Fixtures for "no hidden children" scenario — all mailboxes are subscribed.
  static final subscribedFolder = Mailbox(
    id: MailboxId(Id('subscribedFolder')),
    name: MailboxName('subscribedFolder'),
    parentId: null,
    role: null,
    sortOrder: SortOrder(sortValue: 1000),
    totalEmails: TotalEmails(UnsignedInt(0)),
    unreadEmails: UnreadEmails(UnsignedInt(0)),
    totalThreads: TotalThreads(UnsignedInt(0)),
    unreadThreads: UnreadThreads(UnsignedInt(0)),
    myRights: MailboxRights(true, true, true, true, true, true, true, true, true),
    isSubscribed: IsSubscribed(true),
  );

  static final subscribedChild = Mailbox(
    id: MailboxId(Id('subscribedChild')),
    name: MailboxName('subscribedChild'),
    parentId: MailboxId(Id('subscribedFolder')),
    role: null,
    sortOrder: SortOrder(sortValue: 1000),
    totalEmails: TotalEmails(UnsignedInt(0)),
    unreadEmails: UnreadEmails(UnsignedInt(0)),
    totalThreads: TotalThreads(UnsignedInt(0)),
    unreadThreads: UnreadThreads(UnsignedInt(0)),
    myRights: MailboxRights(true, true, true, true, true, true, true, true, true),
    isSubscribed: IsSubscribed(true),
  );

  static final listMailboxIdsForSubscribedOnly = <MailboxId>[
    MailboxId(Id('subscribedFolder')),
  ];

  static final expectedDeleteListSubscribedOnly = <MailboxId>[
    MailboxId(Id('subscribedChild')),
    MailboxId(Id('subscribedFolder')),
  ];

  // Fixtures for "3-level unsubscribed nesting" scenario.
  // Tree: parentFolder (subscribed) → level1 (unsubscribed) → level2 (unsubscribed) → level3 (unsubscribed)
  static final parentFolder = Mailbox(
    id: MailboxId(Id('parentFolder')),
    name: MailboxName('parentFolder'),
    parentId: null,
    role: null,
    sortOrder: SortOrder(sortValue: 1000),
    totalEmails: TotalEmails(UnsignedInt(0)),
    unreadEmails: UnreadEmails(UnsignedInt(0)),
    totalThreads: TotalThreads(UnsignedInt(0)),
    unreadThreads: UnreadThreads(UnsignedInt(0)),
    myRights: MailboxRights(true, true, true, true, true, true, true, true, true),
    isSubscribed: IsSubscribed(true),
  );

  static final hiddenLevel1 = Mailbox(
    id: MailboxId(Id('hiddenLevel1')),
    name: MailboxName('hiddenLevel1'),
    parentId: MailboxId(Id('parentFolder')),
    role: null,
    sortOrder: SortOrder(sortValue: 1000),
    totalEmails: TotalEmails(UnsignedInt(0)),
    unreadEmails: UnreadEmails(UnsignedInt(0)),
    totalThreads: TotalThreads(UnsignedInt(0)),
    unreadThreads: UnreadThreads(UnsignedInt(0)),
    myRights: MailboxRights(true, true, true, true, true, true, true, true, true),
    isSubscribed: IsSubscribed(false),
  );

  static final hiddenLevel2 = Mailbox(
    id: MailboxId(Id('hiddenLevel2')),
    name: MailboxName('hiddenLevel2'),
    parentId: MailboxId(Id('hiddenLevel1')),
    role: null,
    sortOrder: SortOrder(sortValue: 1000),
    totalEmails: TotalEmails(UnsignedInt(0)),
    unreadEmails: UnreadEmails(UnsignedInt(0)),
    totalThreads: TotalThreads(UnsignedInt(0)),
    unreadThreads: UnreadThreads(UnsignedInt(0)),
    myRights: MailboxRights(true, true, true, true, true, true, true, true, true),
    isSubscribed: IsSubscribed(false),
  );

  static final hiddenLevel3 = Mailbox(
    id: MailboxId(Id('hiddenLevel3')),
    name: MailboxName('hiddenLevel3'),
    parentId: MailboxId(Id('hiddenLevel2')),
    role: null,
    sortOrder: SortOrder(sortValue: 1000),
    totalEmails: TotalEmails(UnsignedInt(0)),
    unreadEmails: UnreadEmails(UnsignedInt(0)),
    totalThreads: TotalThreads(UnsignedInt(0)),
    unreadThreads: UnreadThreads(UnsignedInt(0)),
    myRights: MailboxRights(true, true, true, true, true, true, true, true, true),
    isSubscribed: IsSubscribed(false),
  );

  static final expectedDeleteListThreeLevelNesting = <MailboxId>[
    MailboxId(Id('hiddenLevel3')),
    MailboxId(Id('hiddenLevel2')),
    MailboxId(Id('hiddenLevel1')),
    MailboxId(Id('parentFolder')),
  ];
}