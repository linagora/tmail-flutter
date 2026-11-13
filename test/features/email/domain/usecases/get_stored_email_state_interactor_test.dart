import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_stored_state_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_stored_email_state_interactor.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'get_stored_email_state_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<EmailRepository>()])
void main() {
  group('GetStoredEmailStateInteractor::execute::', () {
    late MockEmailRepository emailRepository;
    late GetStoredEmailStateInteractor interactor;
    final session = DelegationFixtures.session();
    final bobAccountId = DelegationFixtures.bobAccountId;

    setUp(() {
      emailRepository = MockEmailRepository();
      interactor = GetStoredEmailStateInteractor(emailRepository);
    });

    test('the success carries the account it was read for, not my own', () async {
      final state = jmap.State('stored-state');
      when(emailRepository.getEmailState(session, bobAccountId)).thenAnswer((_) async => state);

      await expectLater(
        interactor.execute(session, bobAccountId),
        emitsInOrder([
          Right<Failure, Success>(GetStoredEmailStateSuccess(state, bobAccountId, session.username)),
          emitsDone,
        ]),
      );
    });

    test('emits NotFoundEmailState when no state is stored', () async {
      when(emailRepository.getEmailState(session, bobAccountId)).thenAnswer((_) async => null);

      final results = await interactor.execute(session, bobAccountId).toList();

      expect(results.single.fold((failure) => failure, (_) => null), isA<NotFoundEmailState>());
    });

    test('emits GetStoredEmailStateFailure when the repository throws', () async {
      final exception = Exception('read failed');
      when(emailRepository.getEmailState(session, bobAccountId)).thenThrow(exception);

      final results = await interactor.execute(session, bobAccountId).toList();

      expect(
        results.single.fold((failure) => failure, (_) => null),
        isA<GetStoredEmailStateFailure>().having((f) => f.exception, 'exception', exception),
      );
    });
  });
}
