import 'package:core/utils/app_logger.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/caching/clients/account_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/extensions/account_cache_extensions.dart';
import 'package:tmail_ui_user/features/login/data/extensions/personal_account_extension.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class AccountCacheManager {
  final AccountCacheClient _accountCacheClient;

  AccountCacheManager(this._accountCacheClient);

  Future<PersonalAccount> getSelectedAccount() async {
    try {
      final allAccounts = await _accountCacheClient.getAll();
      return allAccounts.firstWhere((account) => account.isSelected)
          .toAccount();
    } catch (e) {
      logError('AccountCacheManager::getSelectedAccount(): $e');
      throw NotFoundAuthenticatedAccountException();
    }
  }

  Future<void> setSelectedAccount(PersonalAccount account) {
    log('AccountCacheManager::setSelectedAccount(): $_accountCacheClient');
    return _accountCacheClient.insertItem(account.id, account.toCache());
  }

  Future<void> deleteSelectedAccount(String accountId) {
    log('AccountCacheManager::deleteSelectedAccount(): $accountId');
    return _accountCacheClient.deleteItem(accountId);
  }
}