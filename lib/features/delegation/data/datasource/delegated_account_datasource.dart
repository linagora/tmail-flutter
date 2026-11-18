import 'package:delegation/model/delegated_account.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

abstract class DelegatedAccountDatasource {
  Future<List<DelegatedAccount>> getDelegatedAccounts(AccountId accountId);

  Future<void> removeDelegatedAccount(AccountId accountId, Id delegationId);
}
