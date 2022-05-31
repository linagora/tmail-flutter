import 'package:model/account/account.dart';

abstract class AccountDatasource {
  Future<Account> getCurrentAccount();

  Future<void> setCurrentAccount(Account newCurrentAccount);
}