import 'package:delegation/model/delegate.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource/delegate_datasource.dart';
import 'package:tmail_ui_user/features/delegation/data/network/delegate_api.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

class DelegateDatasourceImpl extends DelegateDatasource {
  final DelegateApi _delegateApi;
  final ExceptionThrower _exceptionThrower;

  DelegateDatasourceImpl(this._delegateApi, this._exceptionThrower);

  @override
  Future<List<Delegate>> getDelegates(AccountId accountId) {
    return Future.sync(() => _delegateApi.getDelegates(accountId))
        .catchError(_exceptionThrower.throwException);
  }

  @override
  Future<AddDelegatesResult> addDelegates(AccountId accountId, Set<String> usernames) {
    return Future.sync(() => _delegateApi.addDelegates(accountId, usernames))
        .catchError(_exceptionThrower.throwException);
  }

  @override
  Future<RemoveDelegateResult> removeDelegate(AccountId accountId, Delegate delegate) {
    return Future.sync(() => _delegateApi.removeDelegate(accountId, delegate))
        .catchError(_exceptionThrower.throwException);
  }
}
