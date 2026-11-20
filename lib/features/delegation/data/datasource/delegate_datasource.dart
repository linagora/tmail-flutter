import 'package:delegation/model/delegate.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';

abstract class DelegateDatasource {
  Future<List<Delegate>> getDelegates(AccountId accountId);

  Future<AddDelegatesResult> addDelegates(AccountId accountId, Set<String> usernames);

  Future<RemoveDelegateResult> removeDelegate(AccountId accountId, Delegate delegate);
}
