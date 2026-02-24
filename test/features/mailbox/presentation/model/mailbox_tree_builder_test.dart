import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:model/extensions/list_presentation_mailbox_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/mailbox_state.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';

void main() {
  group('generate mailbox tree: ', () {
    final expectedTree = MailboxTree(
      MailboxNode(
        PresentationMailbox(MailboxId(Id('root'))),
        childrenItems: [
          MailboxNode(
              PresentationMailbox(MailboxId(Id("3")), parentId: null),
              childrenItems: [
                MailboxNode(
                    PresentationMailbox(MailboxId(Id("3_2")), parentId: MailboxId(Id('3'))),
                    childrenItems: [MailboxNode(PresentationMailbox(MailboxId(Id("3_2_1")), parentId: MailboxId(Id('3_2'))))]
                ),
                MailboxNode(
                    PresentationMailbox(MailboxId(Id("3_1")), parentId: MailboxId(Id('3'))),
                    childrenItems: [
                      MailboxNode(PresentationMailbox(MailboxId(Id("3_1_1")), parentId: MailboxId(Id('3_1'))))
                    ]
                ),
              ]
          ),
          MailboxNode(
              PresentationMailbox(MailboxId(Id("1")), parentId: null),
              childrenItems: [
                MailboxNode(
                    PresentationMailbox(MailboxId(Id("1_2")), parentId: MailboxId(Id('1'))),
                    childrenItems: [
                      MailboxNode(PresentationMailbox(MailboxId(Id("1_2_1")), parentId: MailboxId(Id('1_2'))))
                    ]
                ),
                MailboxNode(PresentationMailbox(MailboxId(Id("1_1")), parentId: MailboxId(Id('1')))),
              ]
          ),
          MailboxNode(
              PresentationMailbox(MailboxId(Id("2")), parentId: null),
              childrenItems: [
                MailboxNode(PresentationMailbox(MailboxId(Id("2_2")), parentId: MailboxId(Id('2')))),
                MailboxNode(PresentationMailbox(MailboxId(Id("2_1")), parentId: MailboxId(Id('2'))),
                    childrenItems: [
                      MailboxNode(PresentationMailbox(MailboxId(Id("2_1_2")), parentId: MailboxId(Id('2_1')))),
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id("2_1_1")), parentId: MailboxId(Id('2_1'))),
                          childrenItems: [MailboxNode(PresentationMailbox(MailboxId(Id("2_1_1_1")), parentId: MailboxId(Id('2_1_1'))))]
                      ),
                    ]
                ),
              ]
          ),
        ]
      )
    );

    test('list mailbox is in ordered, parent come first, then children', () async {
      final testCase = [
        PresentationMailbox(MailboxId(Id("1")), parentId: null),
        PresentationMailbox(MailboxId(Id("2")), parentId: null),
        PresentationMailbox(MailboxId(Id("3")), parentId: null),
        PresentationMailbox(MailboxId(Id("1_1")), parentId: MailboxId(Id('1'))),
        PresentationMailbox(MailboxId(Id("1_2")), parentId: MailboxId(Id('1'))),
        PresentationMailbox(MailboxId(Id("1_2_1")), parentId: MailboxId(Id('1_2'))),
        PresentationMailbox(MailboxId(Id("2_1")), parentId: MailboxId(Id('2'))),
        PresentationMailbox(MailboxId(Id("2_2")), parentId: MailboxId(Id('2'))),
        PresentationMailbox(MailboxId(Id("2_1_1")), parentId: MailboxId(Id('2_1'))),
        PresentationMailbox(MailboxId(Id("2_1_1_1")), parentId: MailboxId(Id('2_1_1'))),
        PresentationMailbox(MailboxId(Id("2_1_2")), parentId: MailboxId(Id('2_1'))),
        PresentationMailbox(MailboxId(Id("3_1")), parentId: MailboxId(Id('3'))),
        PresentationMailbox(MailboxId(Id("3_2")), parentId: MailboxId(Id('3'))),
        PresentationMailbox(MailboxId(Id("3_1_1")), parentId: MailboxId(Id('3_1'))),
        PresentationMailbox(MailboxId(Id("3_2_1")), parentId: MailboxId(Id('3_2'))),
      ];

      final generatedTree = await TreeBuilder().generateMailboxTree(testCase);

      expect(generatedTree, equals(expectedTree));
    });

    test('list mailbox is not in ordered, parent come first, then children, then grandpa', () async {
      final testCase = [
        PresentationMailbox(MailboxId(Id("2")), parentId: null),
        PresentationMailbox(MailboxId(Id("3")), parentId: null),
        PresentationMailbox(MailboxId(Id("1_1")), parentId: MailboxId(Id('1'))),
        PresentationMailbox(MailboxId(Id("1_2")), parentId: MailboxId(Id('1'))),
        PresentationMailbox(MailboxId(Id("1_2_1")), parentId: MailboxId(Id('1_2'))),
        PresentationMailbox(MailboxId(Id("1")), parentId: null),
        PresentationMailbox(MailboxId(Id("2_1")), parentId: MailboxId(Id('2'))),
        PresentationMailbox(MailboxId(Id("2_2")), parentId: MailboxId(Id('2'))),
        PresentationMailbox(MailboxId(Id("2_1_1")), parentId: MailboxId(Id('2_1'))),
        PresentationMailbox(MailboxId(Id("2_1_1_1")), parentId: MailboxId(Id('2_1_1'))),
        PresentationMailbox(MailboxId(Id("2_1_2")), parentId: MailboxId(Id('2_1'))),
        PresentationMailbox(MailboxId(Id("3_1")), parentId: MailboxId(Id('3'))),
        PresentationMailbox(MailboxId(Id("3_2")), parentId: MailboxId(Id('3'))),
        PresentationMailbox(MailboxId(Id("3_1_1")), parentId: MailboxId(Id('3_1'))),
        PresentationMailbox(MailboxId(Id("3_2_1")), parentId: MailboxId(Id('3_2'))),
      ];

      final generatedTree = await TreeBuilder().generateMailboxTree(testCase);

      expect(generatedTree.root.childrenItems, containsAll(expectedTree.root.childrenItems!));
      expect(generatedTree.root.childrenItems![2], equals(expectedTree.root.childrenItems![0]));
    });

    test('list mailbox is not in ordered, parent come first, then grandpa, then children', () async {
      final testCase = [
        PresentationMailbox(MailboxId(Id("2")), parentId: null),
        PresentationMailbox(MailboxId(Id("3")), parentId: null),
        PresentationMailbox(MailboxId(Id("1_1")), parentId: MailboxId(Id('1'))),
        PresentationMailbox(MailboxId(Id("1_2")), parentId: MailboxId(Id('1'))),
        PresentationMailbox(MailboxId(Id("1")), parentId: null),
        PresentationMailbox(MailboxId(Id("1_2_1")), parentId: MailboxId(Id('1_2'))),
        PresentationMailbox(MailboxId(Id("2_1")), parentId: MailboxId(Id('2'))),
        PresentationMailbox(MailboxId(Id("2_2")), parentId: MailboxId(Id('2'))),
        PresentationMailbox(MailboxId(Id("2_1_1")), parentId: MailboxId(Id('2_1'))),
        PresentationMailbox(MailboxId(Id("2_1_1_1")), parentId: MailboxId(Id('2_1_1'))),
        PresentationMailbox(MailboxId(Id("2_1_2")), parentId: MailboxId(Id('2_1'))),
        PresentationMailbox(MailboxId(Id("3_1")), parentId: MailboxId(Id('3'))),
        PresentationMailbox(MailboxId(Id("3_2")), parentId: MailboxId(Id('3'))),
        PresentationMailbox(MailboxId(Id("3_1_1")), parentId: MailboxId(Id('3_1'))),
        PresentationMailbox(MailboxId(Id("3_2_1")), parentId: MailboxId(Id('3_2'))),
      ];

      final generatedTree = await TreeBuilder().generateMailboxTree(testCase);

      expect(generatedTree.root.childrenItems, containsAll(expectedTree.root.childrenItems!));
      expect(generatedTree.root.childrenItems![2], equals(expectedTree.root.childrenItems![0]));
    });

    test('list mailbox is not in ordered, children come first, then grandpa, then parent', () async {
      final testCase = [
        PresentationMailbox(MailboxId(Id("2")), parentId: null),
        PresentationMailbox(MailboxId(Id("3")), parentId: null),
        PresentationMailbox(MailboxId(Id("1_2_1")), parentId: MailboxId(Id('1_2'))),
        PresentationMailbox(MailboxId(Id("1")), parentId: null),
        PresentationMailbox(MailboxId(Id("1_1")), parentId: MailboxId(Id('1'))),
        PresentationMailbox(MailboxId(Id("1_2")), parentId: MailboxId(Id('1'))),
        PresentationMailbox(MailboxId(Id("2_1")), parentId: MailboxId(Id('2'))),
        PresentationMailbox(MailboxId(Id("2_2")), parentId: MailboxId(Id('2'))),
        PresentationMailbox(MailboxId(Id("2_1_1")), parentId: MailboxId(Id('2_1'))),
        PresentationMailbox(MailboxId(Id("2_1_1_1")), parentId: MailboxId(Id('2_1_1'))),
        PresentationMailbox(MailboxId(Id("2_1_2")), parentId: MailboxId(Id('2_1'))),
        PresentationMailbox(MailboxId(Id("3_1")), parentId: MailboxId(Id('3'))),
        PresentationMailbox(MailboxId(Id("3_2")), parentId: MailboxId(Id('3'))),
        PresentationMailbox(MailboxId(Id("3_1_1")), parentId: MailboxId(Id('3_1'))),
        PresentationMailbox(MailboxId(Id("3_2_1")), parentId: MailboxId(Id('3_2'))),
      ];

      final generatedTree = await TreeBuilder().generateMailboxTree(testCase);

      expect(generatedTree.root.childrenItems, containsAll(expectedTree.root.childrenItems!));
      expect(generatedTree.root.childrenItems![2], equals(expectedTree.root.childrenItems![0]));
    });

    test('list mailbox is not in ordered, children come first, then parent, then grandpa',  () async {
      final testCase = [
        PresentationMailbox(MailboxId(Id("2")), parentId: null),
        PresentationMailbox(MailboxId(Id("3")), parentId: null),
        PresentationMailbox(MailboxId(Id("1_2_1")), parentId: MailboxId(Id('1_2'))),
        PresentationMailbox(MailboxId(Id("1_1")), parentId: MailboxId(Id('1'))),
        PresentationMailbox(MailboxId(Id("1_2")), parentId: MailboxId(Id('1'))),
        PresentationMailbox(MailboxId(Id("1")), parentId: null),
        PresentationMailbox(MailboxId(Id("2_1")), parentId: MailboxId(Id('2'))),
        PresentationMailbox(MailboxId(Id("2_2")), parentId: MailboxId(Id('2'))),
        PresentationMailbox(MailboxId(Id("2_1_1")), parentId: MailboxId(Id('2_1'))),
        PresentationMailbox(MailboxId(Id("2_1_1_1")), parentId: MailboxId(Id('2_1_1'))),
        PresentationMailbox(MailboxId(Id("2_1_2")), parentId: MailboxId(Id('2_1'))),
        PresentationMailbox(MailboxId(Id("3_1")), parentId: MailboxId(Id('3'))),
        PresentationMailbox(MailboxId(Id("3_2")), parentId: MailboxId(Id('3'))),
        PresentationMailbox(MailboxId(Id("3_1_1")), parentId: MailboxId(Id('3_1'))),
        PresentationMailbox(MailboxId(Id("3_2_1")), parentId: MailboxId(Id('3_2'))),
      ];

      final generatedTree = await TreeBuilder().generateMailboxTree(testCase);

      expect(generatedTree.root.childrenItems, containsAll(expectedTree.root.childrenItems!));
      expect(generatedTree.root.childrenItems![2], equals(expectedTree.root.childrenItems![0]));
    });

    test('item have parent but not found in tree will become root child',  () async {
      final testCase = [
        PresentationMailbox(MailboxId(Id("2")), parentId: null),
        PresentationMailbox(MailboxId(Id("3")), parentId: null),
        PresentationMailbox(MailboxId(Id("1_2_1")), parentId: MailboxId(Id('1_2'))),
        PresentationMailbox(MailboxId(Id("1_1")), parentId: MailboxId(Id('1'))),
        PresentationMailbox(MailboxId(Id("1_2")), parentId: MailboxId(Id('1'))),
        PresentationMailbox(MailboxId(Id("1")), parentId: null),
        PresentationMailbox(MailboxId(Id("2_1")), parentId: MailboxId(Id('2'))),
        PresentationMailbox(MailboxId(Id("2_2")), parentId: MailboxId(Id('2'))),
        PresentationMailbox(MailboxId(Id("2_1_1")), parentId: MailboxId(Id('2_1'))),
        PresentationMailbox(MailboxId(Id("2_1_1_1")), parentId: MailboxId(Id('2_1_1'))),
        PresentationMailbox(MailboxId(Id("2_1_2")), parentId: MailboxId(Id('2_1'))),
        PresentationMailbox(MailboxId(Id("3_1")), parentId: MailboxId(Id('3'))),
        PresentationMailbox(MailboxId(Id("3_2")), parentId: MailboxId(Id('3'))),
        PresentationMailbox(MailboxId(Id("3_1_1")), parentId: MailboxId(Id('3_1'))),
        PresentationMailbox(MailboxId(Id("3_2_1")), parentId: MailboxId(Id('3_2'))),
        PresentationMailbox(MailboxId(Id("e3_2_1")), parentId: MailboxId(Id('id42')))
      ];

      final generatedTree = await TreeBuilder().generateMailboxTree(testCase);

      expect(generatedTree.root.childrenItems?.length, equals(4));
      expect(generatedTree.root.childrenItems,
          contains(MailboxNode(PresentationMailbox(MailboxId(Id("e3_2_1")), parentId: MailboxId(Id('id42'))))));
    });
  });

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
        currentDefaultTree: MailboxTree(MailboxNode.root()),
        currentPersonalTree: MailboxTree(MailboxNode.root()),
        currentTeamMailboxTree: MailboxTree(MailboxNode.root()),
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
        currentDefaultTree: MailboxTree(MailboxNode.root()),
        currentPersonalTree: MailboxTree(MailboxNode.root()),
        currentTeamMailboxTree: MailboxTree(MailboxNode.root()),
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
        currentDefaultTree: MailboxTree(MailboxNode.root()),
        currentPersonalTree: MailboxTree(MailboxNode.root()),
        currentTeamMailboxTree: MailboxTree(MailboxNode.root()),
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
        currentDefaultTree: MailboxTree(MailboxNode.root()),
        currentPersonalTree: MailboxTree(MailboxNode.root()),
        currentTeamMailboxTree: MailboxTree(MailboxNode.root()),
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
        currentDefaultTree: MailboxTree(MailboxNode.root()),
        currentPersonalTree: MailboxTree(MailboxNode.root()),
        currentTeamMailboxTree: MailboxTree(MailboxNode.root()),
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
        currentDefaultTree: MailboxTree(MailboxNode.root()),
        currentPersonalTree: MailboxTree(MailboxNode.root()),
        currentTeamMailboxTree: MailboxTree(MailboxNode.root()),
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
        currentDefaultTree: currentDefaultTree,
        currentPersonalTree: MailboxTree(MailboxNode.root()),
        currentTeamMailboxTree: MailboxTree(MailboxNode.root()),
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
        currentDefaultTree: MailboxTree(MailboxNode.root()),
        currentPersonalTree: MailboxTree(MailboxNode.root()),
        currentTeamMailboxTree: MailboxTree(MailboxNode.root()),
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