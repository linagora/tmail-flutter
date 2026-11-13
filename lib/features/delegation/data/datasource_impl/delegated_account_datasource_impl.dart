import 'package:delegation/model/delegated_account.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource/delegated_account_datasource.dart';
import 'package:tmail_ui_user/features/delegation/data/network/delegated_account_api.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

class DelegatedAccountDatasourceImpl extends DelegatedAccountDatasource {
  final DelegatedAccountApi _delegatedAccountApi;
  final ExceptionThrower _exceptionThrower;

  DelegatedAccountDatasourceImpl(this._delegatedAccountApi, this._exceptionThrower);

  @override
  Future<List<DelegatedAccount>> getDelegatedAccounts(AccountId accountId) {
    return Future.sync(() => _delegatedAccountApi.getDelegatedAccounts(accountId))
        .catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeDelegatedAccount(AccountId accountId, Id delegationId) {
    return Future.sync(() => _delegatedAccountApi.removeDelegatedAccount(accountId, delegationId))
        .catchError(_exceptionThrower.throwException);
  }
}
