import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/caching/clients/account_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';

import 'memory_account_cache_client.dart';

void main() {
  late AccountCacheManager accountCacheManager;
  late AccountCacheClient accountCacheClient;

  group('setCurrentAccount for the same accountId', () {
    setUp(() {
      accountCacheClient = MemoryAccountCacheClient();
      accountCacheManager = AccountCacheManager(accountCacheClient);
    });

    test('WHEN cache have no account \n'
      'AND another account is selected \n'
      'THEN cache will have only new account', () async {
      // arrange
      final personalAccount3 = PersonalAccount(
        '834191067',
        AuthenticationType.oidc,
        isSelected: true,
        accountId: AccountId(Id(
            'ae08b34da40b48f30ec0b94db05675894262fbc5c2e278644f9517aaf25e8246')),
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: UserName('username@domain.com'),
      );

      // act
      await accountCacheManager.setCurrentAccount(personalAccount3);

      // assert
      final allAccounts = await accountCacheClient.getAll();
      expect(allAccounts.length, 1);
      final result = await accountCacheManager.getCurrentAccount(); 
      expect(result, personalAccount3);
    });

    test('WHEN cache have one selected account \n'
         'AND another account which have same accountId is selected \n'
         'THEN cache will have only new account', () async {
      // arrange
      final account1 = AccountCache(
        '253956617',
        'oidc',
        isSelected: true,
        accountId:
            'ae08b34da40b48f30ec0b94db05675894262fbc5c2e278644f9517aaf25e8246',
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: 'username@domain.com',
      );

      final personalAccount3 = PersonalAccount(
        '834191067',
        AuthenticationType.oidc,
        isSelected: true,
        accountId: AccountId(Id(
            'ae08b34da40b48f30ec0b94db05675894262fbc5c2e278644f9517aaf25e8246')),
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: UserName('username@domain.com'),
      );

      accountCacheClient.insertMultipleItem({
        account1.id: account1,
      });

      // act
      await accountCacheManager.setCurrentAccount(personalAccount3);

      // assert
      final allAccounts = await accountCacheClient.getAll();
      expect(allAccounts.length, 1);
      final result = await accountCacheManager.getCurrentAccount(); 
      expect(result, personalAccount3);
    });

    test('WHEN cache have two selected account \n'
      'AND another account which have the same accountId is selected \n'
      'THEN cache will have only new account', () async {
      // arrange
      final account1 = AccountCache(
        '253956617',
        'oidc',
        isSelected: true,
        accountId:
            'ae08b34da40b48f30ec0b94db05675894262fbc5c2e278644f9517aaf25e8246',
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: 'username@domain.com',
      );
      final account2 = AccountCache(
        '60734964',
        'oidc',
        isSelected: true,
        accountId:
            'ae08b34da40b48f30ec0b94db05675894262fbc5c2e278644f9517aaf25e8246',
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: 'username@domain.com',
      );
      final personalAccount3 = PersonalAccount(
        '834191067',
        AuthenticationType.oidc,
        isSelected: true,
        accountId: AccountId(Id(
            'ae08b34da40b48f30ec0b94db05675894262fbc5c2e278644f9517aaf25e8246')),
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: UserName('username@domain.com'),
      );

      accountCacheClient.insertMultipleItem({
        account1.id: account1,
        account2.id: account2,
      });

      // act
      await accountCacheManager.setCurrentAccount(personalAccount3);

      // assert
      final allAccounts = await accountCacheClient.getAll();
      expect(allAccounts.length, 1);
      final result = await accountCacheManager.getCurrentAccount(); 
      expect(result, personalAccount3);
    });
  });

  group('setCurrentAccount for different accountId', () {
    setUp(() {
      accountCacheClient = MemoryAccountCacheClient();
      accountCacheManager = AccountCacheManager(accountCacheClient);
    });

    test('WHEN cache have one selected account \n'
         'AND another account is selected \n'
         'THEN cache will update with new selection', () async {
      // arrange
      final account1 = AccountCache(
        '253956617',
        'oidc',
        isSelected: true,
        accountId:
            '5c2e278644f9517aaf25e8246ae08b34da40b48f30ec0b94db05675894262fbc',
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: 'name@domain.com',
      );

      final personalAccount3 = PersonalAccount(
        '834191067',
        AuthenticationType.oidc,
        isSelected: true,
        accountId: AccountId(Id(
            'ae08b34da40b48f30ec0b94db05675894262fbc5c2e278644f9517aaf25e8246')),
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: UserName('username@domain.com'),
      );

      accountCacheClient.insertItem(account1.id, account1);

      // act
      await accountCacheManager.setCurrentAccount(personalAccount3);

      // assert
      final allAccounts = await accountCacheClient.getAll();
      expect(allAccounts.length, 2);

      final oldSelected = await accountCacheClient.getItem(account1.id);
      expect(oldSelected!.isSelected, false);
      
      final newSelected = await accountCacheManager.getCurrentAccount(); 
      expect(newSelected, personalAccount3);
      expect(newSelected.isSelected, true);
    });

    test('WHEN cache have two selected account \n'
      'AND another account is selected \n'
      'THEN cache will update with new selected account', () async {
      // arrange
      final account1 = AccountCache(
        '253956617',
        'oidc',
        isSelected: true,
        accountId:
            'f30ec0b94db05675894262fbc5c2e27ae08b34da40b488644f9517aaf25e8246',
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: 'usernameA@domain.com',
      );
      final account2 = AccountCache(
        '60734964',
        'oidc',
        isSelected: true,
        accountId:
            '4db05675894262fbc5c2e27ae08b34da40b48f30ec0b98644f9517aaf25e8246',
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: 'usernameB@domain.com',
      );
      final personalAccount3 = PersonalAccount(
        '834191067',
        AuthenticationType.oidc,
        isSelected: true,
        accountId: AccountId(Id(
            '5675894262fbc5c2e278644f9517aaf25e8246ae08b34da40b48f30ec0b94db0')),
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: UserName('usernameC@domain.com'),
      );

      accountCacheClient.insertMultipleItem({
        account1.id: account1,
        account2.id: account2,
      });

      // act
      await accountCacheManager.setCurrentAccount(personalAccount3);

      // assert
      final allAccounts = await accountCacheClient.getAll();
      expect(allAccounts.length, 3);

      final oldOne = await accountCacheClient.getItem(account1.id);
      expect(oldOne!.isSelected, false);

      final oldTwo = await accountCacheClient.getItem(account2.id);
      expect(oldTwo!.isSelected, false);

      final newSelected = await accountCacheManager.getCurrentAccount(); 
      expect(newSelected, personalAccount3);
      expect(newSelected.isSelected, true);
    });
  });
}
