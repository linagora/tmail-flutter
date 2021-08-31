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
}