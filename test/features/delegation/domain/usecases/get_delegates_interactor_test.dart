import 'package:dartz/dartz.dart';
import 'package:delegation/model/delegate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegate_repository.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/get_delegates_state.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/get_delegates_interactor.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'get_delegates_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DelegateRepository>()])
void main() {
  final session = DelegationFixtures.session();
  final personalAccountId = DelegationFixtures.aliceAccountId;
  final otherAccountId = DelegationFixtures.bobAccountId;
  final delegate = Delegate(id: Id('delegate-1'), username: 'bob@example.com');
  late MockDelegateRepository repository;
  late GetDelegatesInteractor interactor;

  setUp(() {
    repository = MockDelegateRepository();
    interactor = GetDelegatesInteractor(repository);
  });

  test('should read the delegates of my personal account, never a delegated one', () async {
    when(repository.getDelegates(personalAccountId)).thenAnswer((_) async => [delegate]);

    await expectLater(
      interactor.execute(session),
      emitsInOrder([
        Right(GettingDelegates()),
        Right(GetDelegatesSuccess([delegate])),
      ]),
    );
    verify(repository.getDelegates(personalAccountId)).called(1);
    verifyNever(repository.getDelegates(otherAccountId));
  });

  test('should emit a failure when the repository throws', () {
    final exception = Exception('network');
    when(repository.getDelegates(personalAccountId)).thenThrow(exception);

    expect(
      interactor.execute(session),
      emitsInOrder([
        Right(GettingDelegates()),
        Left(GetDelegatesFailure(exception)),
      ]),
    );
  });
}
