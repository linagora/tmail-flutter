import 'package:delegation/model/delegated_account.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource/delegated_account_datasource.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegated_account_repository.dart';

class DelegatedAccountRepositoryImpl extends DelegatedAccountRepository {
  final DelegatedAccountDatasource _datasource;

  DelegatedAccountRepositoryImpl(this._datasource);

  @override
  Future<List<DelegatedAccount>> getDelegatedAccounts(AccountId accountId) =>
      _datasource.getDelegatedAccounts(accountId);

  @override
  Future<void> removeDelegatedAccount(AccountId accountId, Id delegationId) =>
      _datasource.removeDelegatedAccount(accountId, delegationId);
}
