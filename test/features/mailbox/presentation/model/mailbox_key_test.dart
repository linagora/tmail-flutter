import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/mailbox_key.dart';

void main() {
  group('MailboxKey', () {
    final accountA = AccountId(Id('accountA'));
    final accountB = AccountId(Id('accountB'));
    final mailbox1 = MailboxId(Id('1'));

    test('keys with the same account and mailbox id are equal', () {
      expect(
        MailboxKey(accountA, mailbox1),
        equals(MailboxKey(accountA, mailbox1)),
      );
      expect(
        MailboxKey(accountA, mailbox1).hashCode,
        equals(MailboxKey(accountA, mailbox1).hashCode),
      );
    });

    test('the same mailbox id in different accounts is not equal', () {
      expect(
        MailboxKey(accountA, mailbox1),
        isNot(equals(MailboxKey(accountB, mailbox1))),
      );
    });

    test('distinguishes accounts when used as a HashMap key', () {
      final map = HashMap<MailboxKey, String>();
      map[MailboxKey(accountA, mailbox1)] = 'a';
      map[MailboxKey(accountB, mailbox1)] = 'b';

      expect(map.length, 2);
      expect(map[MailboxKey(accountA, mailbox1)], 'a');
      expect(map[MailboxKey(accountB, mailbox1)], 'b');
    });

    test('asString combines account and mailbox id', () {
      expect(MailboxKey(accountA, mailbox1).asString, 'accountA:1');
    });
  });
}
