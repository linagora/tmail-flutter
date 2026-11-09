import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_account_key.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';

void main() {
  const userName = 'alice@domain.tld';
  const otherUserName = 'alice@domain.tld.extra';
  const accountId = 'bob-account-id';

  String encoded(String objectId, String account, String user) =>
      TupleKey(objectId, account, user).encodeKey;

  group('CacheAccountKey', () {
    test('reads the account id of this user from an encoded tuple key', () {
      final key = encoded('email-1', accountId, userName);

      expect(CacheAccountKey.accountIdOf(CacheAccountKey.tryDecode(key)!, userName), accountId);
      expect(
        CacheAccountKey.belongsTo(
          decoded: CacheAccountKey.tryDecode(key)!,
          accountId: accountId,
          userName: userName,
        ),
        isTrue,
      );
    });

    test('reads the account id when the user name is not the last part', () {
      const key = 'reopenComposerBrowser|$accountId|$userName|composer-1';

      expect(CacheAccountKey.accountIdOf(key, userName), accountId);
    });

    test('ignores another username, including one that starts with this one', () {
      final other = encoded('email-1', accountId, otherUserName);

      expect(
        CacheAccountKey.accountIdOf(CacheAccountKey.tryDecode(other)!, userName),
        isNull,
      );
    });

    test('ignores a key that is not a tuple of this user', () {
      expect(CacheAccountKey.accountIdOf('Email', userName), isNull);
      expect(CacheAccountKey.tryDecode('not-base64'), isNull);
      expect(CacheAccountKey.accountIdOf('email|$accountId|', userName), isNull);
    });

    test('reads the account id from the second part when the third is this user', () {
      expect(CacheAccountKey.accountIdOf('obj|user|user', 'user'), 'user');
      expect(CacheAccountKey.accountIdOf('obj|acc|user', 'user'), 'acc');
      expect(CacheAccountKey.accountIdOf('user|acc|user', 'user'), 'acc');
      expect(CacheAccountKey.accountIdOf('obj|acc|user2', 'user'), isNull);
      expect(CacheAccountKey.accountIdOf('out|alice|bob', 'alice'), isNull);
      expect(CacheAccountKey.accountIdOf('$accountId|$userName', userName), isNull);
    });

    test('resolves every stored key shape for this user', () {
      const shapes = <String, String>{
        'composer entry': 'composer-1|$accountId|$userName',
        'thread email': 'email-1|$accountId|$userName',
        'thread email id': 'email-id|$accountId|$userName',
        'opened email': 'opened-1|$accountId|$userName',
        'new email': 'new-1|$accountId|$userName',
        'sending email': 'sending-1|$accountId|$userName',
        'web composer': 'reopenComposerBrowser|$accountId|$userName|composer-1',
        'mailbox': 'mailbox-1|$accountId|$userName',
        'state': 'email|$accountId|$userName',
        'fcm state': 'Email|$accountId|$userName',
      };

      for (final entry in shapes.entries) {
        expect(
          CacheAccountKey.accountIdOf(entry.value, userName),
          accountId,
          reason: entry.key,
        );
      }
    });

    test('reads no account id when the signed-in user name is empty', () {
      expect(CacheAccountKey.accountIdOf('email-1|$accountId|', ''), isNull);
      expect(CacheAccountKey.accountIdOf('email-1|$accountId|$userName', ''), isNull);
    });

    test('reads no account id when the account part is empty', () {
      expect(CacheAccountKey.accountIdOf('email-1||$userName', userName), isNull);
    });

    test('a key of another account or another user does not belong to this account', () {
      expect(
        CacheAccountKey.belongsTo(
          decoded: 'email-1|other-account-id|$userName',
          accountId: accountId,
          userName: userName,
        ),
        isFalse,
      );
      expect(
        CacheAccountKey.belongsTo(
          decoded: 'email-1|$accountId|$otherUserName',
          accountId: accountId,
          userName: userName,
        ),
        isFalse,
      );
    });
  });
}
