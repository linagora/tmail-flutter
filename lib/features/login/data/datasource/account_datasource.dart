import 'package:model/account/personal_account.dart';

abstract class AccountDatasource {
  Future<PersonalAccount> getCurrentAccount();

  Future<void> setCurrentAccount(PersonalAccount newCurrentAccount);

  Future<void> deleteCurrentAccount(String accountId);
}