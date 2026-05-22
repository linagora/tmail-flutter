import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/home/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';

import '../../../../fixtures/session_fixtures.dart';
import 'get_session_interactor_test.mocks.dart';

Matcher _emitsNetworkThenCacheThen(dynamic result) => emitsInOrder([
  Right<Failure, Success>(GetSessionLoading()),
  Right<Failure, Success>(GetSessionLoading()),
  result,
]);

@GenerateMocks([SessionRepository])
void main() {
  late MockSessionRepository sessionRepository;
  late GetSessionInteractor interactor;

  setUp(() {
    sessionRepository = MockSessionRepository();
    interactor = GetSessionInteractor(sessionRepository);
  });

  group('[GetSessionInteractor]', () {
    group('on success', () {
      setUp(() {
        when(sessionRepository.getSession())
            .thenAnswer((_) async => SessionFixtures.aliceSession);
      });

      test('emits Loading then Success', () {
        expect(
          interactor.execute(),
          emitsInOrder([
            Right<Failure, Success>(GetSessionLoading()),
            Right<Failure, Success>(GetSessionSuccess(SessionFixtures.aliceSession)),
          ]),
        );
      });

      test('never calls getStoredSession when network succeeds', () async {
        await interactor.execute().drain();
        verifyNever(sessionRepository.getStoredSession());
      });
    });

    group('on network failure (mobile)', () {
      final networkException = Exception('network error');

      setUp(() {
        when(sessionRepository.getSession()).thenThrow(networkException);
      });

      test('calls getStoredSession after getSession throws', () async {
        when(sessionRepository.getStoredSession())
            .thenAnswer((_) async => SessionFixtures.aliceSession);

        await interactor.execute().drain();

        // getSession must be called first, getStoredSession second
        verifyInOrder([
          sessionRepository.getSession(),
          sessionRepository.getStoredSession(),
        ]);
      });

      test('emits Loading, Loading, then CacheSuccess when cache hit', () {
        when(sessionRepository.getStoredSession())
            .thenAnswer((_) async => SessionFixtures.aliceSession);

        expect(
          interactor.execute(),
          _emitsNetworkThenCacheThen(
            Right<Failure, Success>(GetSessionSuccess(SessionFixtures.aliceSession)),
          ),
        );
      });

      test('emits Failure with original network exception when cache also fails', () {
        when(sessionRepository.getStoredSession())
            .thenThrow(Exception('cache miss'));

        expect(
          interactor.execute(),
          _emitsNetworkThenCacheThen(
            Left<Failure, Success>(GetSessionFailure(networkException)),
          ),
        );
      });
    });
  });
}
