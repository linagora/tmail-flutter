import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_rights.dart';
import 'package:model/extensions/list_presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

void main() {
  final accountId = AccountId(Id('otherUser'));

  MailboxRights rights({required bool mayReadItems}) =>
      MailboxRights(mayReadItems, false, false, false, false, false, false,
          false, false);

  PresentationMailbox mailbox({
    required String id,
    required String name,
    bool subscribed = false,
    Role? role,
    MailboxRights? myRights,
  }) =>
      PresentationMailbox(
        MailboxId(Id(id)),
        accountId: accountId,
        name: MailboxName(name),
        role: role,
        isSubscribed: IsSubscribed(subscribed),
        myRights: myRights,
      );

  // A delegated account: an unsubscribed Inbox (system folder), a subscribed
  // custom folder, and an unsubscribed custom folder.
  final mailboxes = [
    mailbox(id: '1', name: 'Inbox', role: PresentationMailbox.roleInbox),
    mailbox(id: '2', name: 'Shared Project', subscribed: true),
    mailbox(id: '3', name: 'Hidden Notes'),
  ];

  group('list mailbox sidebar filters', () {
    test('listSubscribedMailboxesAndDefaultMailboxes keeps system folders', () {
      final names = mailboxes.listSubscribedMailboxesAndDefaultMailboxes
          .map((m) => m.name?.name)
          .toList();
      // The unsubscribed Inbox stays because it is a role (default) mailbox.
      expect(names, containsAll(['Inbox', 'Shared Project']));
      expect(names, isNot(contains('Hidden Notes')));
    });

    test('listSubscribedMailboxes drops the unsubscribed system folder', () {
      final names = mailboxes.listSubscribedMailboxes
          .map((m) => m.name?.name)
          .toList();
      // Strict subscription: only the subscribed folder survives, the
      // unsubscribed delegated Inbox is hidden.
      expect(names, ['Shared Project']);
    });
  });

  group('listReadableMailboxes (ghost account detection)', () {
    test('excludes mailboxes with mayReadItems == false', () {
      final list = [
        mailbox(id: '1', name: 'No Access', myRights: rights(mayReadItems: false)),
        mailbox(id: '2', name: 'Readable', myRights: rights(mayReadItems: true)),
      ];
      expect(
        list.listReadableMailboxes.map((m) => m.name?.name),
        ['Readable'],
      );
    });

    test('treats null myRights as readable', () {
      final list = [mailbox(id: '1', name: 'Unknown Rights')];
      expect(list.listReadableMailboxes.map((m) => m.name?.name), ['Unknown Rights']);
    });

    test('an account with only unreadable mailboxes is a ghost (empty)', () {
      final ghost = [
        mailbox(id: '1', name: 'Inbox', role: PresentationMailbox.roleInbox,
            myRights: rights(mayReadItems: false)),
      ];
      expect(ghost.listReadableMailboxes, isEmpty);
    });
  });
}
