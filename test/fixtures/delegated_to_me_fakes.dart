import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:delegation/model/delegated_account.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegated_account_repository.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';

/// The interactor yields its loading state before it calls the repository.
Future<void> untilRepositoryCalled() => Future<void>.delayed(Duration.zero);

class FakeDelegatedAccountRepository implements DelegatedAccountRepository {
  final List<Completer<List<DelegatedAccount>>> pendingLoads = [];
  final List<Id> removedIds = [];
  Object? removeError;

  /// Holds every removal until it completes, when set.
  Completer<void>? removeGate;

  @override
  Future<List<DelegatedAccount>> getDelegatedAccounts(AccountId accountId) {
    final load = Completer<List<DelegatedAccount>>();
    pendingLoads.add(load);
    return load.future;
  }

  @override
  Future<void> removeDelegatedAccount(AccountId accountId, Id delegationId) async {
    final error = removeError;
    if (error != null) throw error;
    removedIds.add(delegationId);
    await removeGate?.future;
  }
}

class FakeGetSessionInteractor implements GetSessionInteractor {
  Either<Failure, Success>? result;
  int calls = 0;

  @override
  Stream<Either<Failure, Success>> execute({StateChange? stateChange}) async* {
    calls++;
    yield result!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
