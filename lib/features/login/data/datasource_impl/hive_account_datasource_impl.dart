import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class HiveAccountDatasourceImpl extends AccountDatasource {

  final AccountCacheManager _accountCacheManager;
  final ExceptionThrower _exceptionThrower;

  HiveAccountDatasourceImpl(this._accountCacheManager, this._exceptionThrower);

  @override
  Future<PersonalAccount> getCurrentAccount() {
    return Future.sync(() async {
      return await _accountCacheManager.getSelectedAccount();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> setCurrentAccount(PersonalAccount newCurrentAccount) {
    return Future.sync(() async {
      return await _accountCacheManager.setSelectedAccount(newCurrentAccount);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> deleteCurrentAccount(String accountId) {
    return Future.sync(() async {
      return await _accountCacheManager.deleteSelectedAccount(accountId);
    }).catchError(_exceptionThrower.throwException);
  }
}