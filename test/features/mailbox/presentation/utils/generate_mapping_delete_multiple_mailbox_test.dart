import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';

void main() {
  group('generate mapping delete multiple mailbox test', () {

    final expectedMapOfTwoMailboxId = {
      MailboxId(Id("A")): [
        MailboxId(Id('A_1_1')),
        MailboxId(Id('A_1')),
        MailboxId(Id('A_2_1')),
        MailboxId(Id('A_2')),
        MailboxId(Id('A'))
      ],
      MailboxId(Id("B_1")): [MailboxId(Id('B_1'))],
    };

    final expectedListMailboxId = [
      MailboxId(Id('A_1_1')),
      MailboxId(Id('A_1')),
      MailboxId(Id('A_2_1')),
      MailboxId(Id('A_2')),
      MailboxId(Id('A')),
      MailboxId(Id('B_1')),
    ];

    final expectedMapOfOneMailboxId = {
      MailboxId(Id("A")): [
        MailboxId(Id('A_1_1')),
        MailboxId(Id('A_1')),
        MailboxId(Id('A_2_1')),
        MailboxId(Id('A_2')),
        MailboxId(Id('A'))
      ]
    };

    final expectedMapOfThreeMailboxId = {
      MailboxId(Id("A")): [
        MailboxId(Id('A_1_1')),
        MailboxId(Id('A_1')),
        MailboxId(Id('A_2_1')),
        MailboxId(Id('A_2')),
        MailboxId(Id('A'))
      ],
      MailboxId(Id("B_1")): [MailboxId(Id('B_1'))],
      MailboxId(Id("C_1")): [MailboxId(Id('C_1'))],
    };

    test('_generateMapDescendantIdsAndMailboxIdList should return map with 2 items when mailboxes belong to 2 different tree', () async {
      final defaultMailboxTree = MailboxTree(MailboxNode(PresentationMailbox(MailboxId(Id('root')))));

      final folderMailboxTree = MailboxTree(
          MailboxNode(
              PresentationMailbox(MailboxId(Id('root'))),
              childrenItems: [
                MailboxNode(
                    PresentationMailbox(MailboxId(Id('A')), parentId: null),
                    childrenItems: [
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id('A_2')), parentId: MailboxId(Id('A'))),
                          childrenItems: [
                            MailboxNode(PresentationMailbox(MailboxId(Id('A_2_1')), parentId: MailboxId(Id('A_2'))))
                          ]
                      ),
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id('A_1')), parentId: MailboxId(Id('A'))),
                          childrenItems: [
                            MailboxNode(PresentationMailbox(MailboxId(Id('A_1_1')), parentId: MailboxId(Id('A_1'))))
                          ]
                      ),
                    ]
                ),
                MailboxNode(
                    PresentationMailbox(MailboxId(Id('B')), parentId: null),
                    childrenItems: [
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id('B_2')), parentId: MailboxId(Id('B'))),
                          childrenItems: [
                            MailboxNode(PresentationMailbox(MailboxId(Id('B_2_1')), parentId: MailboxId(Id('B_2'))))
                          ]
                      ),
                      MailboxNode(PresentationMailbox(MailboxId(Id('B_1')), parentId: MailboxId(Id('B')))),
                    ]
                )
              ]
          )
      );

      final selectedMailboxList = [
        PresentationMailbox(MailboxId(Id("A")), parentId: null),
        PresentationMailbox(MailboxId(Id('A_1')), parentId: MailboxId(Id('A'))),
        PresentationMailbox(MailboxId(Id('A_2_1')), parentId: MailboxId(Id('A_2'))),
        PresentationMailbox(MailboxId(Id("B_1")), parentId: MailboxId(Id('B')))
      ];

      final tupleResult = MailboxUtils.generateMapDescendantIdsAndMailboxIdList(
          selectedMailboxList,
          defaultMailboxTree,
          folderMailboxTree);

      expect(tupleResult.value1, equals(expectedMapOfTwoMailboxId));
    });

    test('_generateMapDescendantIdsAndMailboxIdList should return list with 5 item when mailboxes belong to 2 different tree', () async {
      final defaultMailboxTree = MailboxTree(MailboxNode(PresentationMailbox(MailboxId(Id('root')))));

      final folderMailboxTree = MailboxTree(
          MailboxNode(
              PresentationMailbox(MailboxId(Id('root'))),
              childrenItems: [
                MailboxNode(
                    PresentationMailbox(MailboxId(Id('A')), parentId: null),
                    childrenItems: [
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id('A_2')), parentId: MailboxId(Id('A'))),
                          childrenItems: [
                            MailboxNode(PresentationMailbox(MailboxId(Id('A_2_1')), parentId: MailboxId(Id('A_2'))))
                          ]
                      ),
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id('A_1')), parentId: MailboxId(Id('A'))),
                          childrenItems: [
                            MailboxNode(PresentationMailbox(MailboxId(Id('A_1_1')), parentId: MailboxId(Id('A_1'))))
                          ]
                      ),
                    ]
                ),
                MailboxNode(
                    PresentationMailbox(MailboxId(Id('B')), parentId: null),
                    childrenItems: [
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id('B_2')), parentId: MailboxId(Id('B'))),
                          childrenItems: [
                            MailboxNode(PresentationMailbox(MailboxId(Id('B_2_1')), parentId: MailboxId(Id('B_2'))))
                          ]
                      ),
                      MailboxNode(PresentationMailbox(MailboxId(Id('B_1')), parentId: MailboxId(Id('B')))),
                    ]
                )
              ]
          )
      );

      final selectedMailboxList = [
        PresentationMailbox(MailboxId(Id("A")), parentId: null),
        PresentationMailbox(MailboxId(Id('A_1')), parentId: MailboxId(Id('A'))),
        PresentationMailbox(MailboxId(Id('A_2_1')), parentId: MailboxId(Id('A_2'))),
        PresentationMailbox(MailboxId(Id("B_1")), parentId: MailboxId(Id('B')))
      ];

      final tupleResult = MailboxUtils.generateMapDescendantIdsAndMailboxIdList(
          selectedMailboxList,
          defaultMailboxTree,
          folderMailboxTree);

      expect(tupleResult.value2, equals(expectedListMailboxId));
    });

    test('_generateMapDescendantIdsAndMailboxIdList should return map with 1 items when mailboxes belong to 2 different tree', () async {
      final defaultMailboxTree = MailboxTree(MailboxNode(PresentationMailbox(MailboxId(Id('root')))));

      final folderMailboxTree = MailboxTree(
          MailboxNode(
              PresentationMailbox(MailboxId(Id('root'))),
              childrenItems: [
                MailboxNode(
                    PresentationMailbox(MailboxId(Id('A')), parentId: null),
                    childrenItems: [
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id('A_2')), parentId: MailboxId(Id('A'))),
                          childrenItems: [
                            MailboxNode(PresentationMailbox(MailboxId(Id('A_2_1')), parentId: MailboxId(Id('A_2'))))
                          ]
                      ),
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id('A_1')), parentId: MailboxId(Id('A'))),
                          childrenItems: [
                            MailboxNode(PresentationMailbox(MailboxId(Id('A_1_1')), parentId: MailboxId(Id('A_1'))))
                          ]
                      ),
                    ]
                ),
                MailboxNode(
                    PresentationMailbox(MailboxId(Id('B')), parentId: null),
                    childrenItems: [
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id('B_2')), parentId: MailboxId(Id('B'))),
                          childrenItems: [
                            MailboxNode(PresentationMailbox(MailboxId(Id('B_2_1')), parentId: MailboxId(Id('B_2'))))
                          ]
                      ),
                      MailboxNode(PresentationMailbox(MailboxId(Id('B_1')), parentId: MailboxId(Id('B')))),
                    ]
                )
              ]
          )
      );

      final selectedMailboxList = [
        PresentationMailbox(MailboxId(Id("A")), parentId: null),
      ];

      final tupleResult = MailboxUtils.generateMapDescendantIdsAndMailboxIdList(
          selectedMailboxList,
          defaultMailboxTree,
          folderMailboxTree);

      expect(tupleResult.value1, equals(expectedMapOfOneMailboxId));
    });

    test('_generateMapDescendantIdsAndMailboxIdList should return map with 3 items when mailboxes belong to 2 different tree', () async {
      final defaultMailboxTree = MailboxTree(MailboxNode(PresentationMailbox(MailboxId(Id('root')))));

      final folderMailboxTree = MailboxTree(
          MailboxNode(
              PresentationMailbox(MailboxId(Id('root'))),
              childrenItems: [
                MailboxNode(
                    PresentationMailbox(MailboxId(Id('A')), parentId: null),
                    childrenItems: [
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id('A_2')), parentId: MailboxId(Id('A'))),
                          childrenItems: [
                            MailboxNode(PresentationMailbox(MailboxId(Id('A_2_1')), parentId: MailboxId(Id('A_2'))))
                          ]
                      ),
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id('A_1')), parentId: MailboxId(Id('A'))),
                          childrenItems: [
                            MailboxNode(PresentationMailbox(MailboxId(Id('A_1_1')), parentId: MailboxId(Id('A_1'))))
                          ]
                      ),
                    ]
                ),
                MailboxNode(
                    PresentationMailbox(MailboxId(Id('B')), parentId: null),
                    childrenItems: [
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id('B_2')), parentId: MailboxId(Id('B'))),
                          childrenItems: [
                            MailboxNode(PresentationMailbox(MailboxId(Id('B_2_1')), parentId: MailboxId(Id('B_2'))))
                          ]
                      ),
                      MailboxNode(PresentationMailbox(MailboxId(Id('B_1')), parentId: MailboxId(Id('B')))),
                    ]
                ),
                MailboxNode(
                    PresentationMailbox(MailboxId(Id('C')), parentId: null),
                    childrenItems: [
                      MailboxNode(
                          PresentationMailbox(MailboxId(Id('C_2')), parentId: MailboxId(Id('C'))),
                          childrenItems: [
                            MailboxNode(PresentationMailbox(MailboxId(Id('C_2_1')), parentId: MailboxId(Id('C_2'))))
                          ]
                      ),
                      MailboxNode(PresentationMailbox(MailboxId(Id('C_1')), parentId: MailboxId(Id('C')))),
                    ]
                )
              ]
          )
      );

      final selectedMailboxList = [
        PresentationMailbox(MailboxId(Id("A")), parentId: null),
        PresentationMailbox(MailboxId(Id("B_1")), parentId: MailboxId(Id('B'))),
        PresentationMailbox(MailboxId(Id("C_1")), parentId: MailboxId(Id('C')))
      ];

      final tupleResult = MailboxUtils.generateMapDescendantIdsAndMailboxIdList(
          selectedMailboxList,
          defaultMailboxTree,
          folderMailboxTree);

      expect(tupleResult.value1, equals(expectedMapOfThreeMailboxId));
    });
  });
}