import 'package:core/utils/app_logger.dart';
import 'package:model/account/account.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';

class AccountRepositoryImpl extends AccountRepository {

  final AccountDatasource _accountDatasource;

  AccountRepositoryImpl(this._accountDatasource);

  @override
  Future<Account> getCurrentAccount() {
    return _accountDatasource.getCurrentAccount();
  }

  @override
  Future<void> setCurrentAccount(Account newCurrentAccount) {
    log('AccountRepositoryImpl::setCurrentAccount(): $newCurrentAccount');
    return _accountDatasource.setCurrentAccount(newCurrentAccount);
  }

  @override
  Future<void> deleteCurrentAccount(String accountId) {
    return _accountDatasource.deleteCurrentAccount(accountId);
  }
}