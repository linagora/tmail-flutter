import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';

class AccountRepositoryImpl extends AccountRepository {

  final AccountDatasource _accountDatasource;

  AccountRepositoryImpl(this._accountDatasource);

  @override
  Future<PersonalAccount> getCurrentAccount() {
    return _accountDatasource.getCurrentAccount();
  }

  @override
  Future<void> setCurrentAccount(PersonalAccount newCurrentAccount) {
    return _accountDatasource.setCurrentAccount(newCurrentAccount);
  }

  @override
  Future<void> deleteCurrentAccount(String hashId) {
    return _accountDatasource.deleteCurrentAccount(hashId);
  }

  @override
  Future<List<PersonalAccount>> getAllAccount() {
    return _accountDatasource.getAllAccount();
  }

  @override
  Future<void> setCurrentActiveAccount(PersonalAccount activeAccount) {
    return _accountDatasource.setCurrentActiveAccount(activeAccount);
  }
}