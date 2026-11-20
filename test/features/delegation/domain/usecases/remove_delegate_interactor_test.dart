import 'package:dartz/dartz.dart';
import 'package:delegation/model/delegate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegate_repository.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/remove_delegate_state.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/remove_delegate_interactor.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'remove_delegate_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DelegateRepository>()])
void main() {
  final session = DelegationFixtures.session();
  final personalAccountId = DelegationFixtures.aliceAccountId;
  final otherAccountId = DelegationFixtures.bobAccountId;
  final delegate = Delegate(id: Id('delegate-1'), username: 'bob@example.com');
  late MockDelegateRepository repository;
  late RemoveDelegateInteractor interactor;

  setUp(() {
    repository = MockDelegateRepository();
    interactor = RemoveDelegateInteractor(repository);
  });

  test('should remove the delegate from my personal account and emit success', () async {
    final result = RemoveDelegateResult(removedDelegate: delegate, delegates: []);
    when(repository.removeDelegate(personalAccountId, delegate)).thenAnswer((_) async => result);

    await expectLater(
      interactor.execute(session, delegate),
      emitsInOrder([
        Right(RemovingDelegate()),
        Right(RemoveDelegateSuccess(result)),
      ]),
    );
    verify(repository.removeDelegate(personalAccountId, delegate)).called(1);
    verifyNever(repository.removeDelegate(otherAccountId, any));
  });

  test('should emit a failure when the repository throws', () {
    final exception = Exception('forbidden');
    when(repository.removeDelegate(personalAccountId, delegate)).thenThrow(exception);

    expect(
      interactor.execute(session, delegate),
      emitsInOrder([
        Right(RemovingDelegate()),
        Left(RemoveDelegateFailure(exception)),
      ]),
    );
  });
}
