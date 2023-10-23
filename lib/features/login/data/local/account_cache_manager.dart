import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/caching/clients/account_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/extensions/account_cache_extensions.dart';
import 'package:tmail_ui_user/features/login/data/extensions/personal_account_extension.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class AccountCacheManager {
  final AccountCacheClient _accountCacheClient;

  AccountCacheManager(this._accountCacheClient);

  Future<PersonalAccount> getCurrentAccount() async {
    final allAccounts = await _accountCacheClient.getAll();
    log('AccountCacheManager::getCurrentAccount::allAccounts(): $allAccounts');
    final accountCache = allAccounts.firstWhereOrNull((account) => account.isSelected);
    log('AccountCacheManager::getCurrentAccount::accountCache(): $accountCache');
    if (accountCache != null) {
      return accountCache.toAccount();
    } else {
      throw NotFoundAuthenticatedAccountException();
    }
  }

  Future<void> setCurrentAccount(PersonalAccount account) async {
    log('AccountCacheManager::setCurrentAccount(): $account');
    final accountCacheExist = await _accountCacheClient.isExistTable();
    if (accountCacheExist) {
      await _accountCacheClient.clearAllData();
    }
    return _accountCacheClient.insertItem(account.id, account.toCache());
  }

  Future<void> deleteCurrentAccount(String hashId) {
    log('AccountCacheManager::deleteCurrentAccount(): $hashId');
    return _accountCacheClient.deleteItem(hashId);
  }
}