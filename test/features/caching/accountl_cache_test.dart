
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/data/extensions/list_account_cache_extensions.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';

void main() {
  group('AccountCache test', () {
    test('removeDuplicated should remove duplicate accountId', () async {
      final account1 = AccountCache(
        id: '1',
        authType: 'oidc',
        isSelected: true,
        baseUrl: 'https://example.com',
        accountId: '1',
        userName: '1',
        apiUrl: 'https://example.com/jmap'
      );
      final account2 = AccountCache(
        id: '2',
        authType: 'oidc',
        isSelected: true,
        baseUrl: 'https://example.com',
        accountId: '1',
        userName: '1',
        apiUrl: 'https://example.com/jmap'
      );
      final account3 = AccountCache(
        id: '3',
        authType: 'basic',
        isSelected: true,
        baseUrl: 'https://example.com',
        accountId: '2',
        userName: '2',
        apiUrl: 'https://example.com/jmap'
      );
      final account4 = AccountCache(
        id: '4',
        authType: 'basic',
        isSelected: true,
        baseUrl: 'https://example.com',
        accountId: '2',
        userName: '2',
        apiUrl: 'https://example.com/jmap'
      );

      final result = [account1, account2, account3, account4].removeDuplicated();
      expect(result, equals([account1, account3]));
    });
  });
}