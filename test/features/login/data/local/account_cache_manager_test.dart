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

  group('setCurrentAccount prune logic', () {
    setUp(() {
      accountCacheClient = MemoryAccountCacheClient();
      accountCacheManager = AccountCacheManager(accountCacheClient);
    });

    test('WHEN a stored account has the SAME accountId but a different hash id \n'
        '(token refresh changed the id) \n'
        'THEN the stale version is REMOVED, leaving only the new account', () async {
      const sharedAccountId =
          'ae08b34da40b48f30ec0b94db05675894262fbc5c2e278644f9517aaf25e8246';
      final staleVersion = AccountCache(
        'old-hash',
        'oidc',
        isSelected: true,
        accountId: sharedAccountId,
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: 'username@domain.com',
      );
      final refreshedAccount = PersonalAccount(
        'new-hash',
        AuthenticationType.oidc,
        isSelected: true,
        accountId: AccountId(Id(sharedAccountId)),
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: UserName('username@domain.com'),
      );
      await accountCacheClient.insertItem(staleVersion.id, staleVersion);

      // act
      await accountCacheManager.setCurrentAccount(refreshedAccount);

      // assert — old hash gone, only the new one remains and is selected
      final allAccounts = await accountCacheClient.getAll();
      expect(allAccounts.length, 1);
      expect(await accountCacheClient.getItem('old-hash'), isNull);
      final current = await accountCacheManager.getCurrentAccount();
      expect(current.id, 'new-hash');
      expect(current.isSelected, true);
    });

    test('WHEN the box has duplicate entries for one accountId \n'
        'THEN setting a different account collapses the duplicates \n'
        'AND keeps exactly one selected account', () async {
      const duplicatedAccountId =
          'f30ec0b94db05675894262fbc5c2e27ae08b34da40b488644f9517aaf25e8246';
      final dup1 = AccountCache(
        'dup-1',
        'oidc',
        isSelected: true,
        accountId: duplicatedAccountId,
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: 'dup@domain.com',
      );
      final dup2 = AccountCache(
        'dup-2',
        'oidc',
        isSelected: true,
        accountId: duplicatedAccountId,
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: 'dup@domain.com',
      );
      final newAccount = PersonalAccount(
        'new-hash',
        AuthenticationType.oidc,
        isSelected: true,
        accountId: AccountId(Id(
            '5675894262fbc5c2e278644f9517aaf25e8246ae08b34da40b48f30ec0b94db0')),
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: UserName('new@domain.com'),
      );
      await accountCacheClient.insertMultipleItem({
        dup1.id: dup1,
        dup2.id: dup2,
      });

      // act
      await accountCacheManager.setCurrentAccount(newAccount);

      // assert — duplicates collapsed to one (unselected) + new (selected)
      final allAccounts = await accountCacheClient.getAll();
      expect(allAccounts.length, 2);
      expect(allAccounts.where((account) => account.isSelected).length, 1);
      final current = await accountCacheManager.getCurrentAccount();
      expect(current.id, 'new-hash');
    });

    test('WHEN re-selecting the account that is already stored \n'
        '(same id, same accountId) \n'
        'THEN the box still holds exactly that one selected account', () async {
      const accountId =
          'aaaa894262fbc5c2e278644f9517aaf25e8246ae08b34da40b48f30ec0b94db0';
      final existing = AccountCache(
        'same-hash',
        'oidc',
        isSelected: true,
        accountId: accountId,
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: 'self@domain.com',
      );
      final reselect = PersonalAccount(
        'same-hash',
        AuthenticationType.oidc,
        isSelected: true,
        accountId: AccountId(Id(accountId)),
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        userName: UserName('self@domain.com'),
      );
      await accountCacheClient.insertItem(existing.id, existing);

      // act
      await accountCacheManager.setCurrentAccount(reselect);

      // assert — idempotent: one selected account, not pruned to empty
      final allAccounts = await accountCacheClient.getAll();
      expect(allAccounts.length, 1);
      final current = await accountCacheManager.getCurrentAccount();
      expect(current.id, 'same-hash');
      expect(current.isSelected, true);
    });
  });
}
