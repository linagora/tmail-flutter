import 'dart:async';

import 'package:delegation/model/delegate.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegate_repository.dart';

/// Each read stays pending until the test completes it, so in-flight states can be checked.
class FakeDelegateRepository implements DelegateRepository {
  final List<AccountId> getCalls = [];
  final List<Completer<List<Delegate>>> pendingGets = [];

  @override
  Future<List<Delegate>> getDelegates(AccountId accountId) {
    getCalls.add(accountId);
    final get = Completer<List<Delegate>>();
    pendingGets.add(get);
    return get.future;
  }

  @override
  Future<AddDelegatesResult> addDelegates(AccountId accountId, Set<String> usernames) =>
      throw UnimplementedError();

  @override
  Future<RemoveDelegateResult> removeDelegate(AccountId accountId, Delegate delegate) =>
      throw UnimplementedError();
}
