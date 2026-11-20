import 'package:delegation/model/delegate.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource/delegate_datasource.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegate_repository.dart';

class DelegateRepositoryImpl extends DelegateRepository {
  final DelegateDatasource _datasource;

  DelegateRepositoryImpl(this._datasource);

  @override
  Future<List<Delegate>> getDelegates(AccountId accountId) =>
      _datasource.getDelegates(accountId);

  @override
  Future<AddDelegatesResult> addDelegates(AccountId accountId, Set<String> usernames) =>
      _datasource.addDelegates(accountId, usernames);

  @override
  Future<RemoveDelegateResult> removeDelegate(AccountId accountId, Delegate delegate) =>
      _datasource.removeDelegate(accountId, delegate);
}
