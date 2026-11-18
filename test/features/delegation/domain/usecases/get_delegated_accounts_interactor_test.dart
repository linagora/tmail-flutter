import 'package:dartz/dartz.dart';
import 'package:delegation/model/delegated_account.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegated_account_repository.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/get_delegated_accounts_state.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/get_delegated_accounts_interactor.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'get_delegated_accounts_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DelegatedAccountRepository>()])
void main() {
  final session = DelegationFixtures.session();
  final personalAccountId = DelegationFixtures.aliceAccountId;
  final delegatedAccount = DelegatedAccount(id: Id('delegation-1'), username: 'owner@example.com');
  late MockDelegatedAccountRepository repository;
  late GetDelegatedAccountsInteractor interactor;

  setUp(() {
    repository = MockDelegatedAccountRepository();
    interactor = GetDelegatedAccountsInteractor(repository);
  });

  test('should read the delegated accounts of my personal account, never a delegated one', () {
    when(repository.getDelegatedAccounts(personalAccountId)).thenAnswer((_) async => [delegatedAccount]);

    expect(
      interactor.execute(session),
      emitsInOrder([
        Right(GettingDelegatedAccounts()),
        Right(GetDelegatedAccountsSuccess([delegatedAccount])),
      ]),
    );
  });

  test('should emit a failure when the repository throws', () {
    final exception = Exception('network');
    when(repository.getDelegatedAccounts(personalAccountId)).thenThrow(exception);

    expect(
      interactor.execute(session),
      emitsInOrder([
        Right(GettingDelegatedAccounts()),
        Left(GetDelegatedAccountsFailure(exception)),
      ]),
    );
  });
}
