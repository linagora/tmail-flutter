import 'package:core/utils/platform_info.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class HiveAccountDatasourceImpl extends AccountDatasource {

  final AccountCacheManager _accountCacheManager;
  final IOSSharingManager _iosSharingManager;
  final ExceptionThrower _exceptionThrower;

  HiveAccountDatasourceImpl(
    this._accountCacheManager,
    this._iosSharingManager,
    this._exceptionThrower
  );

  @override
  Future<PersonalAccount> getCurrentAccount() {
    return Future.sync(() async {
      return await _accountCacheManager.getCurrentAccount();
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> setCurrentAccount(PersonalAccount newCurrentAccount) {
    return Future.sync(() async {
      await _accountCacheManager.setCurrentAccount(newCurrentAccount);
      if (PlatformInfo.isIOS) {
        await _iosSharingManager.saveKeyChainSharingSession(newCurrentAccount);
      }
      return Future.value(null);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> deleteCurrentAccount(String accountId) {
    return Future.sync(() async {
      return await _accountCacheManager.deleteCurrentAccount(accountId);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}