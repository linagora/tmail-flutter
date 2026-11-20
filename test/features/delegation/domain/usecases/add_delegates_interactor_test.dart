import 'package:dartz/dartz.dart';
import 'package:delegation/model/delegate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegate_repository.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/add_delegates_state.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/add_delegates_interactor.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'add_delegates_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DelegateRepository>()])
void main() {
  final session = DelegationFixtures.session();
  final personalAccountId = DelegationFixtures.aliceAccountId;
  final otherAccountId = DelegationFixtures.bobAccountId;
  final usernames = {'bob@example.com', 'unknown@example.com'};
  final delegate = Delegate(id: Id('delegate-1'), username: 'bob@example.com');
  late MockDelegateRepository repository;
  late AddDelegatesInteractor interactor;

  setUp(() {
    repository = MockDelegateRepository();
    interactor = AddDelegatesInteractor(repository);
  });

  test('should add delegates on my personal account and emit success', () async {
    final result = AddDelegatesResult(
      addedUsernames: ['bob@example.com', 'unknown@example.com'],
      rejectedUsernames: {},
      delegates: [delegate],
    );
    when(repository.addDelegates(personalAccountId, usernames)).thenAnswer((_) async => result);

    await expectLater(
      interactor.execute(session, usernames),
      emitsInOrder([
        Right(AddingDelegates()),
        Right(AddDelegatesSuccess(result)),
      ]),
    );
    verify(repository.addDelegates(personalAccountId, usernames)).called(1);
    verifyNever(repository.addDelegates(otherAccountId, any));
  });

  test('should emit success when some usernames are rejected', () async {
    final result = AddDelegatesResult(
      addedUsernames: ['bob@example.com'],
      rejectedUsernames: {
        'unknown@example.com': SetError(SetError.invalidArguments),
      },
      delegates: [delegate],
    );
    when(repository.addDelegates(personalAccountId, usernames)).thenAnswer((_) async => result);

    await expectLater(
      interactor.execute(session, usernames),
      emitsInOrder([
        Right(AddingDelegates()),
        Right(AddDelegatesSuccess(result)),
      ]),
    );
  });

  test('should emit a failure when the repository throws', () {
    final exception = Exception('forbidden');
    when(repository.addDelegates(personalAccountId, usernames)).thenThrow(exception);

    expect(
      interactor.execute(session, usernames),
      emitsInOrder([
        Right(AddingDelegates()),
        Left(AddDelegatesFailure(exception)),
      ]),
    );
  });
}
