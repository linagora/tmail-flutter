import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/linagora_ecosystem_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_linagora_ecosystem_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_linagora_ecosystem_interactor.dart';

import 'get_linagora_ecosystem_interactor_test.mocks.dart';

@GenerateMocks([LinagoraEcosystemRepository, LinagoraEcosystem])
void main() {
  late GetLinagoraEcosystemInteractor interactor;
  late MockLinagoraEcosystemRepository mockRepository;

  setUp(() {
    mockRepository = MockLinagoraEcosystemRepository();
    interactor = GetLinagoraEcosystemInteractor(mockRepository);
  });

  const baseUrl = 'https://example.com';

  group('GetLinagoraEcosystemInteractor', () {
    test(
      'should emit [Getting, Success] when repository returns data successfully',
      () async {
        // Arrange
        final ecosystem = MockLinagoraEcosystem();

        when(mockRepository.getLinagoraEcosystem(any))
            .thenAnswer((_) async => ecosystem);

        // Act
        final stream = interactor.execute(baseUrl);

        // Assert
        expectLater(
          stream,
          emitsInOrder([
            predicate<Either>(
              (either) => either.fold(
                (_) => false,
                (success) => success is GettingLinagraEcosystem,
              ),
            ),
            predicate<Either>(
              (either) => either.fold(
                (_) => false,
                (success) =>
                    success is GetLinagraEcosystemSuccess &&
                    success.linagoraEcosystem == ecosystem,
              ),
            ),
          ]),
        );

        await untilCalled(mockRepository.getLinagoraEcosystem(baseUrl));

        verify(mockRepository.getLinagoraEcosystem(baseUrl)).called(1);
      },
    );

    test(
      'should emit [Getting, Failure] when repository throws an exception',
      () async {
        // Arrange
        final tException = Exception('Network Error');

        when(mockRepository.getLinagoraEcosystem(any)).thenThrow(tException);

        // Act
        final stream = interactor.execute(baseUrl);

        // Assert
        expectLater(
          stream,
          emitsInOrder([
            predicate<Either>(
              (either) => either.fold(
                (_) => false,
                (success) => success is GettingLinagraEcosystem,
              ),
            ),
            predicate<Either>(
              (either) => either.fold(
                (failure) =>
                    failure is GetLinagraEcosystemFailure &&
                    failure.exception == tException,
                (_) => false,
              ),
            ),
          ]),
        );

        await untilCalled(mockRepository.getLinagoraEcosystem(baseUrl));

        verify(mockRepository.getLinagoraEcosystem(baseUrl)).called(1);
      },
    );
  });
}
