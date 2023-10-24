
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/data/extensions/list_account_cache_extensions.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';

void main() {
  group('AccountCache test', () {
    test('removeDuplicated should remove duplicate accountId', () async {
      final account1 = AccountCache(
        '1',
        'oidc',
        isSelected: true,
        accountId: '1',
        userName: '1',
        apiUrl: 'https://example.com/jmap'
      );
      final account2 = AccountCache(
        '2',
        'oidc',
        isSelected: true,
        accountId: '1',
        userName: '1',
        apiUrl: 'https://example.com/jmap'
      );
      final account3 = AccountCache(
        '3',
        'basic',
        isSelected: true,
        accountId: '2',
        userName: '2',
        apiUrl: 'https://example.com/jmap'
      );
      final account4 = AccountCache(
        '4',
        'basic',
        isSelected: true,
        accountId: '2',
        userName: '2',
        apiUrl: 'https://example.com/jmap'
      );

      final result = [account1, account2, account3, account4].removeDuplicated();
      expect(result, equals([account1, account3]));
    });
  });
}