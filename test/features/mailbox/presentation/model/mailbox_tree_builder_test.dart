import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
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
}