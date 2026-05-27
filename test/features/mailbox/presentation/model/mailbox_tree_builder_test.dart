import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_rights.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:model/extensions/list_presentation_mailbox_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/mailbox_state.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_collection.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';

void main() {
  group('generate default mailbox tree base on sortOrder: ', () {
    final expectedTree = MailboxTree(
        MailboxNode(
            PresentationMailbox(MailboxId(Id('root'))),
            childrenItems: [
              MailboxNode(
                PresentationMailbox(MailboxId(Id("1")), parentId: null, name: MailboxName('Inbox'), sortOrder: SortOrder(sortValue: 10), role: Role('inbox')),
              ),
              MailboxNode(
                PresentationMailbox(MailboxId(Id("2")), parentId: null, name: MailboxName('Draft'), sortOrder: SortOrder(sortValue: 30), role: Role('draft')),
              ),
              MailboxNode(
                PresentationMailbox(MailboxId(Id("3")), parentId: null, name: MailboxName('Outbox'), sortOrder: SortOrder(sortValue: 40), role: Role('outbox')),
              ),
              MailboxNode(
                PresentationMailbox(MailboxId(Id("4")), parentId: null, name: MailboxName('Sent'), sortOrder: SortOrder(sortValue: 50), role: Role('sent')),
              ),
              MailboxNode(
                PresentationMailbox(MailboxId(Id("5")), parentId: null, name: MailboxName('Trash'), sortOrder: SortOrder(sortValue: 60), role: Role('trash')),
              ),
              MailboxNode(
                PresentationMailbox(MailboxId(Id("6")), parentId: null, name: MailboxName('Spam'), sortOrder: SortOrder(sortValue: 70), role: Role('spam')),
              ),
            ]
        )
    );


    test('defaultMailboxTree should be in order after buildTree', () async {
      final testCase = [
        PresentationMailbox(MailboxId(Id("4")), parentId: null, name: MailboxName('Sent'), sortOrder: SortOrder(sortValue: 50), role: Role('sent')),
        PresentationMailbox(MailboxId(Id("6")), parentId: null, name: MailboxName('Spam'), sortOrder: SortOrder(sortValue: 70), role: Role('spam')),
        PresentationMailbox(MailboxId(Id("5")), parentId: null, name: MailboxName('Trash'), sortOrder: SortOrder(sortValue: 60), role: Role('trash')),
        PresentationMailbox(MailboxId(Id("2")), parentId: null, name: MailboxName('Draft'), sortOrder: SortOrder(sortValue: 30), role: Role('draft')),
        PresentationMailbox(MailboxId(Id("3")), parentId: null, name: MailboxName('Outbox'), sortOrder: SortOrder(sortValue: 40), role: Role('outbox')),
        PresentationMailbox(MailboxId(Id("1")), parentId: null, name: MailboxName('Inbox'), sortOrder: SortOrder(sortValue: 10), role: Role('inbox')),
      ];

      final generatedTree = await TreeBuilder().generateMailboxTreeInUI(
        allMailboxes: testCase,
        currentCollection: MailboxCollection.empty(),
      );

      expect(
        generatedTree.defaultTree.root.childrenItems,
        equals(expectedTree.root.childrenItems)
      );
    });
  });

  group('Virtual Folders Exclusion & Sorting Impact', () {
    late List<PresentationMailbox> filteredMailboxes;
    final virtualStarred = PresentationMailbox.favoriteFolder;
    final virtualActionRequired = PresentationMailbox.actionRequiredFolder;

    setUp(() {
      final allMailboxesIncludingVirtual = [
        PresentationMailbox(
          MailboxId(Id("default_root")),
          parentId: null,
          name: MailboxName('Inbox'),
          role: Role('inbox'),
          sortOrder: SortOrder(sortValue: 10),
        ),
        PresentationMailbox(
          MailboxId(Id("default_child")),
          parentId: MailboxId(Id("default_root")),
          name: MailboxName('Sub Inbox'),
        ),
        PresentationMailbox(
          MailboxId(Id("personal_root")),
          parentId: null,
          name: MailboxName('My Folder'),
          namespace: Namespace('Personal'),
        ),
        PresentationMailbox(
          MailboxId(Id("team_root")),
          parentId: null,
          name: MailboxName('Team Folder'),
          namespace: Namespace('Team'),
        ),
        virtualStarred,
        virtualActionRequired,
      ];

      filteredMailboxes = allMailboxesIncludingVirtual.withoutVirtualMailbox;
    });

    void expectNoVirtualFoldersRecursively(List<MailboxNode>? nodes) {
      if (nodes == null || nodes.isEmpty) return;
      for (final node in nodes) {
        expect(
          node.item.isVirtualFolder,
          isFalse,
          reason: 'Found Virtual Folder: ${node.item.name?.name}',
        );
        expectNoVirtualFoldersRecursively(node.childrenItems);
      }
    }

    test(
        'generateMailboxTreeInUI: Trees and nested sub-trees must exclude virtual folders',
        () async {
      final generatedTrees = await TreeBuilder().generateMailboxTreeInUI(
        allMailboxes: filteredMailboxes,
        currentCollection: MailboxCollection.empty(),
      );

      expectNoVirtualFoldersRecursively(
        generatedTrees.defaultTree.root.childrenItems,
      );
      expectNoVirtualFoldersRecursively(
        generatedTrees.personalTree.root.childrenItems,
      );
      expectNoVirtualFoldersRecursively(
        generatedTrees.teamMailboxTree.root.childrenItems,
      );
      expect(
        generatedTrees.allMailboxes,
        everyElement(
            isNot(predicate<PresentationMailbox>((m) => m.isVirtualFolder))),
      );
    });

    test(
        'generateMailboxTreeInUIAfterRefreshChanges: Trees and nested sub-trees must exclude virtual folders',
        () async {
      final generatedTrees =
          await TreeBuilder().generateMailboxTreeInUIAfterRefreshChanges(
        allMailboxes: filteredMailboxes,
        currentCollection: MailboxCollection.empty(),
      );

      expectNoVirtualFoldersRecursively(
        generatedTrees.defaultTree.root.childrenItems,
      );
      expectNoVirtualFoldersRecursively(
        generatedTrees.personalTree.root.childrenItems,
      );
      expectNoVirtualFoldersRecursively(
        generatedTrees.teamMailboxTree.root.childrenItems,
      );
    });

    test(
        'Inbox is first when virtual folders are excluded via withoutVirtualMailbox before generateMailboxTreeInUI',
        () async {
      final allMailboxesIncludingVirtual = [
        PresentationMailbox(
          MailboxId(Id("4")),
          parentId: null,
          name: MailboxName('Sent'),
          sortOrder: SortOrder(sortValue: 50),
          role: Role('sent'),
        ),
        PresentationMailbox(
          MailboxId(Id("1")),
          parentId: null,
          name: MailboxName('Inbox'),
          sortOrder: SortOrder(sortValue: 10),
          role: Role('inbox'),
        ),
        virtualStarred,
        virtualActionRequired,
      ];

      final filtered = allMailboxesIncludingVirtual.withoutVirtualMailbox;

      final generatedTree = await TreeBuilder().generateMailboxTreeInUI(
        allMailboxes: filtered,
        currentCollection: MailboxCollection.empty(),
      );

      final children = generatedTree.defaultTree.root.childrenItems ?? [];
      expect(
        children,
        isNotEmpty,
        reason:
            'Default tree must have at least one mailbox after filtering virtual folders',
      );
      expect(
        children.first.item.id.id.value,
        equals('1'),
        reason:
            'Inbox (sortOrder=10) must be first when virtual folders are excluded',
      );
      expect(
        children,
        everyElement(
            isNot(predicate<MailboxNode>((n) => n.item.isVirtualFolder))),
        reason: 'No virtual folders should appear in the tree',
      );
    });

    test(
        'Regression: Virtual folders with null sortOrder sort to top when passed to generateMailboxTreeInUI',
        () async {
      final testCaseWithVirtualFolders = [
        PresentationMailbox(MailboxId(Id("4")),
            parentId: null,
            name: MailboxName('Sent'),
            sortOrder: SortOrder(sortValue: 50),
            role: Role('sent')),
        PresentationMailbox(MailboxId(Id("1")),
            parentId: null,
            name: MailboxName('Inbox'),
            sortOrder: SortOrder(sortValue: 10),
            role: Role('inbox')),
        virtualStarred,
      ];

      final generatedTree = await TreeBuilder().generateMailboxTreeInUI(
        allMailboxes: testCaseWithVirtualFolders,
        currentCollection: MailboxCollection.empty(),
      );

      final children = generatedTree.defaultTree.root.childrenItems ?? [];
      expect(
        children,
        isNotEmpty,
        reason: 'Virtual folder must have been routed to the default tree',
      );
      expect(
        children.first.item.id,
        equals(virtualStarred.id),
        reason:
            'Virtual folder with null sortOrder sorts to top — controller must pass allMailboxes.withoutVirtualMailbox to buildTree',
      );
    });
  });

  group('Routing & Sorting', () {
    test('Mailboxes are routed to correct trees and sorted alphabetically',
        () async {
      final mailboxes = [
        PresentationMailbox(MailboxId(Id("1")),
            parentId: null, name: MailboxName('Inbox'), role: Role('inbox')),
        PresentationMailbox(MailboxId(Id("3")),
            parentId: MailboxId(Id("1")), name: MailboxName('Zebra')),
        PresentationMailbox(MailboxId(Id("2")),
            parentId: MailboxId(Id("1")), name: MailboxName('Apple')),
        PresentationMailbox(
          MailboxId(Id("4")),
          parentId: null,
          name: MailboxName('Personal'),
          namespace: Namespace('Personal'),
        ),
        PresentationMailbox(
          MailboxId(Id("5")),
          parentId: null,
          name: MailboxName('Team'),
          namespace: Namespace('Team'),
        ),
      ];

      final result =
          await TreeBuilder().generateMailboxTreeInUIAfterRefreshChanges(
        allMailboxes: mailboxes,
        currentCollection: MailboxCollection.empty(),
      );

      expect(result.defaultTree.root.childrenItems?.length, equals(1));
      expect(
        result.personalTree.root.childrenItems,
        isNotEmpty,
        reason: 'Personal tree must have at least one mailbox',
      );
      expect(
        result.personalTree.root.childrenItems?.first.item.name?.name,
        equals('Personal'),
      );
      expect(
        result.teamMailboxTree.root.childrenItems,
        isNotEmpty,
        reason: 'Team tree must have at least one mailbox',
      );
      expect(
        result.teamMailboxTree.root.childrenItems?.first.item.name?.name,
        equals('Team'),
      );

      final inboxChildren =
          result.defaultTree.root.childrenItems?.first.childrenItems ?? [];
      expect(inboxChildren.length, equals(2));
      expect(
        inboxChildren[0].item.name?.name,
        equals('Apple'),
        reason: 'Apple must sort before Zebra',
      );
      expect(inboxChildren[1].item.name?.name, equals('Zebra'));
    });
  });

  group('UI State Preservation', () {
    test('Preserves expandMode and selectMode from previous trees', () async {
      final targetId = MailboxId(Id("1"));
      final mailbox = PresentationMailbox(
        targetId,
        parentId: null,
        name: MailboxName('Inbox'),
        role: Role('inbox'),
      );

      final oldNode = MailboxNode(
        mailbox,
        expandMode: ExpandMode.EXPAND,
        selectMode: SelectMode.ACTIVE,
      );
      final currentDefaultTree = MailboxTree(MailboxNode.root())
        ..root.addChildNode(oldNode);

      final result =
          await TreeBuilder().generateMailboxTreeInUIAfterRefreshChanges(
        allMailboxes: [mailbox],
        currentCollection: MailboxCollection(
          allMailboxes: const [],
          defaultTree: currentDefaultTree,
          personalTree: MailboxTree(MailboxNode.root()),
          teamMailboxTree: MailboxTree(MailboxNode.root()),
        ),
      );

      final newNode = result.defaultTree.root.childrenItems?.first;
      expect(
        newNode?.expandMode,
        equals(ExpandMode.EXPAND),
        reason: 'expandMode must be carried over',
      );
      expect(
        newNode?.selectMode,
        equals(SelectMode.ACTIVE),
        reason: 'selectMode must be carried over',
      );
    });
  });

  group('MailboxCollection allMailboxes field', () {
    final inbox = PresentationMailbox(
      MailboxId(Id('inbox')),
      name: MailboxName('Inbox'),
      role: Role('inbox'),
    );
    final sent = PresentationMailbox(
      MailboxId(Id('sent')),
      name: MailboxName('Sent'),
      role: Role('sent'),
    );

    test(
      'generateMailboxTreeInUIAfterRefreshChanges: allMailboxes excludes virtual folders from previous collection',
      () async {
        final virtualFavorite = PresentationMailbox.favoriteFolder;
        final previousDefaultTree = MailboxTree(MailboxNode.root())
          ..root.addChildNode(MailboxNode(virtualFavorite));

        final previousCollection = MailboxCollection(
          allMailboxes: [inbox, virtualFavorite],
          defaultTree: previousDefaultTree,
          personalTree: MailboxTree(MailboxNode.root()),
          teamMailboxTree: MailboxTree(MailboxNode.root()),
        );

        final result = await TreeBuilder().generateMailboxTreeInUIAfterRefreshChanges(
          allMailboxes: [inbox, sent],
          currentCollection: previousCollection,
        );

        expect(
          result.allMailboxes.every((m) => !m.isVirtualFolder),
          isTrue,
          reason: 'Virtual folders from previousCollection must not bleed into result.allMailboxes',
        );
        expect(result.allMailboxes.length, equals(2));
      },
    );

    test(
      'generateMailboxTreeInUIAfterRefreshChanges: deleted server mailboxes are excluded from result',
      () async {
        final deleted = PresentationMailbox(
          MailboxId(Id('deleted')),
          name: MailboxName('Old Folder'),
        );
        final previousDefaultTree = MailboxTree(MailboxNode.root())
          ..root.addChildNode(MailboxNode(deleted));

        final previousCollection = MailboxCollection(
          allMailboxes: [inbox, deleted],
          defaultTree: previousDefaultTree,
          personalTree: MailboxTree(MailboxNode.root()),
          teamMailboxTree: MailboxTree(MailboxNode.root()),
        );

        final result = await TreeBuilder().generateMailboxTreeInUIAfterRefreshChanges(
          allMailboxes: [inbox],
          currentCollection: previousCollection,
        );

        expect(result.allMailboxes.length, equals(1));
        expect(
          result.allMailboxes.any((m) => m.id == deleted.id),
          isFalse,
          reason: 'Mailbox removed from server must not appear in result',
        );
      },
    );

    test(
      'generateMailboxTreeInUI: deleted server mailboxes are excluded from result',
      () async {
        final deleted = PresentationMailbox(
          MailboxId(Id('deleted')),
          name: MailboxName('Old Folder'),
        );
        final previousDefaultTree = MailboxTree(MailboxNode.root())
          ..root.addChildNode(MailboxNode(deleted));

        final previousCollection = MailboxCollection(
          allMailboxes: [inbox, deleted],
          defaultTree: previousDefaultTree,
          personalTree: MailboxTree(MailboxNode.root()),
          teamMailboxTree: MailboxTree(MailboxNode.root()),
        );

        final result = await TreeBuilder().generateMailboxTreeInUI(
          allMailboxes: [inbox],
          currentCollection: previousCollection,
        );

        expect(result.allMailboxes.length, equals(1));
        expect(
          result.allMailboxes.any((m) => m.id == deleted.id),
          isFalse,
          reason: 'Mailbox removed from server must not appear in result',
        );
      },
    );

    test(
      'generateMailboxTreeInUI: selected mailbox in allMailboxes has state deactivated',
      () async {
        final result = await TreeBuilder().generateMailboxTreeInUI(
          allMailboxes: [inbox, sent],
          currentCollection: MailboxCollection.empty(),
          mailboxIdSelected: inbox.id,
        );

        final selectedInResult = result.allMailboxes.firstWhere((m) => m.id == inbox.id);
        expect(
          selectedInResult.state,
          equals(MailboxState.deactivated),
          reason: 'Selected mailbox must be deactivated in allMailboxes',
        );
        expect(result.allMailboxes.length, equals(2));
      },
    );
  });

  group('Team Mailbox Sub-folder Sorting', () {
    final teamNamespace = Namespace('Delegated[unite-a@linagora.com]');
    final teamRootId = MailboxId(Id('team_root'));

    List<PresentationMailbox> buildTeamMailboxes() => [
      PresentationMailbox(
        teamRootId,
        parentId: null,
        name: MailboxName('unite-a'),
        namespace: teamNamespace,
      ),
      PresentationMailbox(
        MailboxId(Id('inbox')),
        parentId: teamRootId,
        name: MailboxName('INBOX'),
        namespace: teamNamespace,
        role: Role('inbox'),
      ),
      PresentationMailbox(
        MailboxId(Id('drafts')),
        parentId: teamRootId,
        name: MailboxName('Drafts'),
        namespace: teamNamespace,
        role: Role('drafts'),
      ),
      PresentationMailbox(
        MailboxId(Id('sent')),
        parentId: teamRootId,
        name: MailboxName('Sent'),
        namespace: teamNamespace,
        role: Role('sent'),
      ),
      PresentationMailbox(
        MailboxId(Id('trash')),
        parentId: teamRootId,
        name: MailboxName('Trash'),
        namespace: teamNamespace,
        role: Role('trash'),
      ),
      PresentationMailbox(
        MailboxId(Id('templates')),
        parentId: teamRootId,
        name: MailboxName('Templates'),
        namespace: teamNamespace,
        role: Role('templates'),
      ),
      PresentationMailbox(
        MailboxId(Id('outbox')),
        parentId: teamRootId,
        name: MailboxName('Outbox'),
        namespace: teamNamespace,
        role: Role('outbox'),
      ),
      // User-created folders — intentionally unsorted in input
      PresentationMailbox(
        MailboxId(Id('affaire3')),
        parentId: teamRootId,
        name: MailboxName('affaire-3'),
        namespace: teamNamespace,
      ),
      PresentationMailbox(
        MailboxId(Id('affaire1')),
        parentId: teamRootId,
        name: MailboxName('affaire-1'),
        namespace: teamNamespace,
      ),
      PresentationMailbox(
        MailboxId(Id('affaire2')),
        parentId: teamRootId,
        name: MailboxName('affaire-2'),
        namespace: teamNamespace,
      ),
    ];

    void expectSubfoldersSystemFirstThenAlpha(MailboxCollection result) {
      final teamRootNode = result.teamMailboxTree.root.childrenItems?.first;
      final children = teamRootNode?.childrenItems ?? [];
      expect(children.length, equals(9));
      expect(
        children.map((n) => n.item.name?.name).toList(),
        equals(['INBOX', 'Drafts', 'Outbox', 'Sent', 'Trash', 'Templates', 'affaire-1', 'affaire-2', 'affaire-3']),
        reason: 'Team mailbox sub-folders must list system folders first (canonical order), then user folders alphabetically',
      );
    }

    test('team mailbox sub-folders list system folders first then user folders alphabetically on both build paths', () async {
      final inUIResult = await TreeBuilder().generateMailboxTreeInUI(
        allMailboxes: buildTeamMailboxes(),
        currentCollection: MailboxCollection.empty(),
      );
      expectSubfoldersSystemFirstThenAlpha(inUIResult);

      final afterRefreshResult = await TreeBuilder().generateMailboxTreeInUIAfterRefreshChanges(
        allMailboxes: buildTeamMailboxes(),
        currentCollection: MailboxCollection.empty(),
      );
      expectSubfoldersSystemFirstThenAlpha(afterRefreshResult);
    });

    test('generateMailboxTreeInUI: nested sub-folders within team mailbox are also sorted alphabetically', () async {
      final subFolderParentId = MailboxId(Id('affaire1'));
      final allMailboxes = [
        ...buildTeamMailboxes(),
        PresentationMailbox(
          MailboxId(Id('nested_z')),
          parentId: subFolderParentId,
          name: MailboxName('zebra'),
          namespace: teamNamespace,
        ),
        PresentationMailbox(
          MailboxId(Id('nested_a')),
          parentId: subFolderParentId,
          name: MailboxName('apple'),
          namespace: teamNamespace,
        ),
      ];

      final result = await TreeBuilder().generateMailboxTreeInUI(
        allMailboxes: allMailboxes,
        currentCollection: MailboxCollection.empty(),
      );

      final teamRootNode = result.teamMailboxTree.root.childrenItems?.first;
      final affaire1Node = teamRootNode?.childrenItems
          ?.firstWhere((n) => n.item.name?.name == 'affaire-1');
      final nestedChildren = affaire1Node?.childrenItems ?? [];

      expect(nestedChildren.length, equals(2));
      expect(nestedChildren[0].item.name?.name, equals('apple'));
      expect(nestedChildren[1].item.name?.name, equals('zebra'));
    });

    test('generateMailboxTreeInUI: multiple team mailboxes are sorted alphabetically', () async {
      final uniteANamespace = Namespace('Delegated[unite-a@linagora.com]');
      final uniteBNamespace = Namespace('Delegated[unite-b@linagora.com]');
      final uniteAId = MailboxId(Id('team_unite_a'));
      final uniteBId = MailboxId(Id('team_unite_b'));

      final mailboxes = [
        PresentationMailbox(
          uniteBId,
          parentId: null,
          name: MailboxName('unite-b'),
          namespace: uniteBNamespace,
        ),
        PresentationMailbox(
          uniteAId,
          parentId: null,
          name: MailboxName('unite-a'),
          namespace: uniteANamespace,
        ),
      ];

      final result = await TreeBuilder().generateMailboxTreeInUI(
        allMailboxes: mailboxes,
        currentCollection: MailboxCollection.empty(),
      );

      final teamRoots = result.teamMailboxTree.root.childrenItems ?? [];
      expect(teamRoots.length, equals(2));
      expect(teamRoots[0].item.name?.name, equals('unite-a'));
      expect(teamRoots[1].item.name?.name, equals('unite-b'));
    });
  });

  group('Team Mailbox System-first Sort — Edge Cases', () {
    final teamNamespace = Namespace('Delegated[team@example.com]');
    final teamRootId = MailboxId(Id('team_root'));

    PresentationMailbox teamItem(String id, String name, {Role? role, MailboxRights? myRights}) => PresentationMailbox(
      MailboxId(Id(id)),
      parentId: teamRootId,
      name: MailboxName(name),
      namespace: teamNamespace,
      role: role,
      myRights: myRights,
    );

    // mayReadItems, mayAddItems, mayRemoveItems, maySetSeen, maySetKeywords, mayCreateChild, mayRename, mayDelete, maySubmit
    final systemRights = MailboxRights(true, true, true, true, true, true, false, false, true);
    final userRights   = MailboxRights(true, true, true, true, true, true, true,  true,  true);

    Future<List<MailboxNode>> getSubfolders(List<PresentationMailbox> children) async {
      final result = await TreeBuilder().generateMailboxTreeInUI(
        allMailboxes: [
          PresentationMailbox(teamRootId, parentId: null, name: MailboxName('team'), namespace: teamNamespace),
          ...children,
        ],
        currentCollection: MailboxCollection.empty(),
      );
      return result.teamMailboxTree.root.childrenItems?.first.childrenItems ?? [];
    }

    test('team mailbox with only user folders stays alphabetical', () async {
      final children = await getSubfolders([
        teamItem('z', 'Zebra'),
        teamItem('a', 'Alpha'),
        teamItem('m', 'Medium'),
      ]);
      expect(children.map((n) => n.item.name?.name).toList(), equals(['Alpha', 'Medium', 'Zebra']));
    });

    test('role takes priority over mayDelete+name fallback', () async {
      final children = await getSubfolders([
        teamItem('inbox_fr', 'Boîte de réception', role: Role('inbox')),
        teamItem('inbox_sys', 'INBOX', myRights: systemRights),
        teamItem('aaa', 'aaa', myRights: userRights),
      ]);
      expect(
        children.map((n) => n.item.name?.name).toList(),
        equals(['Boîte de réception', 'INBOX', 'aaa']),
        reason: 'Role is the primary signal; mayDelete=false+name is the fallback — both land before user folders',
      );
    });

    test('no-role system folders (mayDelete=false) sort before user folders via name — on both build paths', () async {
      final teamRoot = PresentationMailbox(teamRootId, parentId: null, name: MailboxName('team'), namespace: teamNamespace);
      final noRoleMailboxes = [
        teamRoot,
        teamItem('abd', 'ABD', myRights: userRights),
        teamItem('inbox', 'INBOX', myRights: systemRights),
        teamItem('drafts', 'Drafts', myRights: systemRights),
        teamItem('sent', 'Sent', myRights: systemRights),
        teamItem('outbox', 'Outbox', myRights: systemRights),
        teamItem('trash', 'Trash', myRights: systemRights),
        teamItem('templates', 'Templates', myRights: systemRights),
      ];
      const expected = ['INBOX', 'Drafts', 'Outbox', 'Sent', 'Trash', 'Templates', 'ABD'];

      final inUIResult = await TreeBuilder().generateMailboxTreeInUI(
        allMailboxes: noRoleMailboxes,
        currentCollection: MailboxCollection.empty(),
      );
      final afterRefreshResult = await TreeBuilder().generateMailboxTreeInUIAfterRefreshChanges(
        allMailboxes: noRoleMailboxes,
        currentCollection: MailboxCollection.empty(),
      );

      for (final result in [inUIResult, afterRefreshResult]) {
        final children = result.teamMailboxTree.root.childrenItems?.first.childrenItems ?? [];
        expect(
          children.map((n) => n.item.name?.name).toList(),
          equals(expected),
          reason: 'When system folders carry no role, mayDelete=false+name-based fallback places them before user folders in canonical order',
        );
      }
    });

    test('user folder named like a system folder (mayDelete=true) sorts alphabetically', () async {
      final children = await getSubfolders([
        teamItem('inbox_sys', 'INBOX', myRights: systemRights),
        teamItem('inbox_user', 'Inbox', myRights: userRights),
        teamItem('abd', 'ABD', myRights: userRights),
      ]);
      expect(
        children.map((n) => n.item.name?.name).toList(),
        equals(['INBOX', 'ABD', 'Inbox']),
        reason: 'mayDelete=true marks a user-created folder — even if the name matches a system folder, it sorts alphabetically with other user folders',
      );
    });

    test('default and personal tree sorting is unaffected by team mailbox sort logic', () async {
      final mailboxes = [
        PresentationMailbox(
          MailboxId(Id('sent')),
          name: MailboxName('Sent'),
          sortOrder: SortOrder(sortValue: 50),
          role: Role('sent'),
        ),
        PresentationMailbox(
          MailboxId(Id('inbox')),
          name: MailboxName('Inbox'),
          sortOrder: SortOrder(sortValue: 10),
          role: Role('inbox'),
        ),
        PresentationMailbox(
          MailboxId(Id('personal_z')),
          name: MailboxName('Zebra'),
          namespace: Namespace('Personal'),
        ),
        PresentationMailbox(
          MailboxId(Id('personal_a')),
          name: MailboxName('Apple'),
          namespace: Namespace('Personal'),
        ),
      ];

      final result = await TreeBuilder().generateMailboxTreeInUI(
        allMailboxes: mailboxes,
        currentCollection: MailboxCollection.empty(),
      );

      final defaultChildren = result.defaultTree.root.childrenItems ?? [];
      expect(
        defaultChildren.map((n) => n.item.name?.name).toList(),
        equals(['Inbox', 'Sent']),
        reason: 'Default tree must still use sortOrder, not system-first name matching',
      );

      final personalChildren = result.personalTree.root.childrenItems ?? [];
      expect(
        personalChildren.map((n) => n.item.name?.name).toList(),
        equals(['Apple', 'Zebra']),
        reason: 'Personal tree must remain alphabetical and unaffected',
      );
    });
  });

  group('Cascading Deactivation (generateMailboxTreeInUI only)', () {
    test('Selecting a parent deactivates it and cascades to its children',
        () async {
      final parentId = MailboxId(Id("parent_1"));
      final childId = MailboxId(Id("child_1"));
      final grandChildId = MailboxId(Id("grandchild_1"));

      final mailboxes = [
        PresentationMailbox(
          parentId,
          parentId: null,
          name: MailboxName('Parent'),
          role: Role('inbox'),
        ),
        PresentationMailbox(
          childId,
          parentId: parentId,
          name: MailboxName('Child'),
        ),
        PresentationMailbox(
          grandChildId,
          parentId: childId,
          name: MailboxName('Grandchild'),
        ),
      ];

      final result = await TreeBuilder().generateMailboxTreeInUI(
        allMailboxes: mailboxes,
        currentCollection: MailboxCollection.empty(),
        mailboxIdSelected: parentId,
      );

      final parentNode = result.defaultTree.root.childrenItems?.first;
      final childNode = parentNode?.childrenItems?.first;
      final grandChildNode = childNode?.childrenItems?.first;

      expect(parentNode?.nodeState, equals(MailboxState.deactivated));
      expect(childNode?.nodeState, equals(MailboxState.deactivated));
      expect(grandChildNode?.nodeState, equals(MailboxState.deactivated));
    });
  });
}