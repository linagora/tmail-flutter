import 'package:core/utils/app_logger.dart';
import 'package:model/account/account.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';

class HiveAccountDatasourceImpl extends AccountDatasource {
  final AccountCacheManager _accountCacheManager;

  HiveAccountDatasourceImpl(this._accountCacheManager);

  @override
  Future<Account> getCurrentAccount() {
    return _accountCacheManager.getSelectedAccount();
  }

  @override
  Future<void> setCurrentAccount(Account newCurrentAccount) {
    log('HiveAccountDatasourceImpl::setCurrentAccount(): $newCurrentAccount');
    log('HiveAccountDatasourceImpl::setCurrentAccount(): $_accountCacheManager');
    return _accountCacheManager.setSelectedAccount(newCurrentAccount);
  }
}