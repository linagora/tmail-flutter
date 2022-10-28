import 'package:model/account/account.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class HiveAccountDatasourceImpl extends AccountDatasource {

  final AccountCacheManager _accountCacheManager;
  final ExceptionThrower _exceptionThrower;

  HiveAccountDatasourceImpl(this._accountCacheManager, this._exceptionThrower);

  @override
  Future<Account> getCurrentAccount() {
    return Future.sync(() async {
      return await _accountCacheManager.getSelectedAccount();
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<void> setCurrentAccount(Account newCurrentAccount) {
    return Future.sync(() async {
      return await _accountCacheManager.setSelectedAccount(newCurrentAccount);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<void> deleteCurrentAccount(String accountId) {
    return Future.sync(() async {
      return await _accountCacheManager.deleteSelectedAccount(accountId);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }
}