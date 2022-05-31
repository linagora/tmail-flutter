
import 'package:model/account/account.dart';

abstract class AccountRepository {
  Future<Account> getCurrentAccount();

  Future<void> setCurrentAccount(Account newCurrentAccount);
}