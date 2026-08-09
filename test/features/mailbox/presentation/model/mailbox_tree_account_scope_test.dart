import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/mailbox_key.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

void main() {
  // getNodePath reads Get.context for display names, which needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  final primaryAccountId = AccountId(Id('primary'));
  final otherAccountId = AccountId(Id('otherUser'));

  // Two accounts each own a folder with the same MailboxId('1').
  PresentationMailbox primaryFolder() => PresentationMailbox(
        MailboxId(Id('1')),
        accountId: primaryAccountId,
        name: MailboxName('PrimaryFolder'),
      );
  PresentationMailbox otherFolder() => PresentationMailbox(
        MailboxId(Id('1')),
        accountId: otherAccountId,
        name: MailboxName('OtherFolder'),
      );

  MailboxTree buildTree() {
    final root = MailboxNode.root();
    root.addChildNode(MailboxNode(primaryFolder()));
    root.addChildNode(MailboxNode(otherFolder()));
    return MailboxTree(root);
  }

  group('MailboxTree account-scoped lookups', () {
    test('findNodeByKey returns the node owned by the requested account', () {
      final tree = buildTree();

      expect(
        tree.findNodeByKey(MailboxKey(primaryAccountId, MailboxId(Id('1'))))
            ?.item.name?.name,
        'PrimaryFolder',
      );
      expect(
        tree.findNodeByKey(MailboxKey(otherAccountId, MailboxId(Id('1'))))
            ?.item.name?.name,
        'OtherFolder',
      );
    });

    test('updateMailboxNameByKey only renames the owning account node', () {
      final tree = buildTree();

      tree.updateMailboxNameByKey(
        MailboxKey(otherAccountId, MailboxId(Id('1'))),
        MailboxName('Renamed'),
      );

      expect(
        tree.findNodeByKey(MailboxKey(otherAccountId, MailboxId(Id('1'))))
            ?.item.name?.name,
        'Renamed',
      );
      expect(
        tree.findNodeByKey(MailboxKey(primaryAccountId, MailboxId(Id('1'))))
            ?.item.name?.name,
        'PrimaryFolder',
        reason: 'the same id in the other account must be untouched',
      );
    });

    test('updateMailboxUnreadCountByKey only touches the owning account node', () {
      final root = MailboxNode.root();
      root.addChildNode(MailboxNode(primaryFolder().copyWith(
        unreadEmails: UnreadEmails(UnsignedInt(5)),
      )));
      root.addChildNode(MailboxNode(otherFolder().copyWith(
        unreadEmails: UnreadEmails(UnsignedInt(5)),
      )));
      final tree = MailboxTree(root);

      tree.updateMailboxUnreadCountByKey(
        MailboxKey(otherAccountId, MailboxId(Id('1'))),
        -5,
      );

      expect(
        tree.findNodeByKey(MailboxKey(otherAccountId, MailboxId(Id('1'))))
            ?.item.unreadEmails?.value.value,
        0,
      );
      expect(
        tree.findNodeByKey(MailboxKey(primaryAccountId, MailboxId(Id('1'))))
            ?.item.unreadEmails?.value.value,
        5,
      );
    });

    test('getNodePath does not cross into another account on the parent walk', () {
      // Each account has a parent id 1 and a child id 2 -> parent 1. The other
      // account's parent is named differently, so a crossed walk is detectable.
      final root = MailboxNode.root();
      root.addChildNode(MailboxNode(PresentationMailbox(
        MailboxId(Id('1')),
        accountId: primaryAccountId,
        name: MailboxName('PrimaryParent'),
      )));
      root.addChildNode(MailboxNode(PresentationMailbox(
        MailboxId(Id('2')),
        accountId: primaryAccountId,
        parentId: MailboxId(Id('1')),
        name: MailboxName('PrimaryChild'),
      )));
      root.addChildNode(MailboxNode(PresentationMailbox(
        MailboxId(Id('1')),
        accountId: otherAccountId,
        name: MailboxName('OtherParent'),
      )));
      root.addChildNode(MailboxNode(PresentationMailbox(
        MailboxId(Id('2')),
        accountId: otherAccountId,
        parentId: MailboxId(Id('1')),
        name: MailboxName('OtherChild'),
      )));
      final tree = MailboxTree(root);

      expect(
        tree.getNodePath(MailboxKey(otherAccountId, MailboxId(Id('2'))), '/'),
        'OtherParent/OtherChild',
      );
      expect(
        tree.getNodePath(MailboxKey(primaryAccountId, MailboxId(Id('2'))), '/'),
        'PrimaryParent/PrimaryChild',
      );
    });
  });
}
