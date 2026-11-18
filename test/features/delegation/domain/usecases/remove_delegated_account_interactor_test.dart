import 'package:dartz/dartz.dart';
import 'package:delegation/model/delegated_account.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegated_account_repository.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/remove_delegated_account_state.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/remove_delegated_account_interactor.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'remove_delegated_account_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DelegatedAccountRepository>()])
void main() {
  final session = DelegationFixtures.session();
  final personalAccountId = DelegationFixtures.aliceAccountId;
  final delegatedAccount = DelegatedAccount(id: Id('delegation-1'), username: 'owner@example.com');
  late MockDelegatedAccountRepository repository;
  late RemoveDelegatedAccountInteractor interactor;

  setUp(() {
    repository = MockDelegatedAccountRepository();
    interactor = RemoveDelegatedAccountInteractor(repository);
  });

  test('should remove the delegation from my personal account and emit the removed account', () async {
    when(repository.removeDelegatedAccount(personalAccountId, delegatedAccount.id)).thenAnswer((_) async {});

    await expectLater(
      interactor.execute(session, delegatedAccount),
      emitsInOrder([
        Right(RemovingDelegatedAccount()),
        Right(RemoveDelegatedAccountSuccess(delegatedAccount)),
      ]),
    );
    verify(repository.removeDelegatedAccount(personalAccountId, delegatedAccount.id)).called(1);
  });

  test('should emit a failure when the repository throws', () {
    final exception = Exception('forbidden');
    when(repository.removeDelegatedAccount(personalAccountId, delegatedAccount.id)).thenThrow(exception);

    expect(
      interactor.execute(session, delegatedAccount),
      emitsInOrder([
        Right(RemovingDelegatedAccount()),
        Left(RemoveDelegatedAccountFailure(exception)),
      ]),
    );
  });
}
