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
  });
}
