import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/linagora_ecosystem_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/linagora_ecosystem_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';

import 'linagora_ecosystem_repository_impl_test.mocks.dart';

@GenerateMocks([LinagoraEcosystemDatasource, LinagoraEcosystem])
void main() {
  late LinagoraEcosystemRepositoryImpl repository;
  late MockLinagoraEcosystemDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockLinagoraEcosystemDatasource();
    repository = LinagoraEcosystemRepositoryImpl(mockDatasource);
  });

  const baseUrl = 'https://example.com';

  group('LinagoraEcosystemRepositoryImpl', () {
    test(
      'should return LinagoraEcosystem when the call to datasource is successful',
      () async {
        // Arrange
        final ecosystem = MockLinagoraEcosystem();

        when(mockDatasource.getLinagoraEcosystem(any))
            .thenAnswer((_) async => ecosystem);

        // Act
        final result = await repository.getLinagoraEcosystem(baseUrl);

        // Assert
        expect(result, equals(ecosystem));
        verify(mockDatasource.getLinagoraEcosystem(baseUrl)).called(1);
        verifyNoMoreInteractions(mockDatasource);
      },
    );

    test(
      'should propagate the exception when the call to datasource fails',
      () async {
        // Arrange
        final exception = Exception('Something went wrong');

        when(mockDatasource.getLinagoraEcosystem(any))
            .thenAnswer((_) async => throw exception);

        // Act
        final call = repository.getLinagoraEcosystem;

        // Assert
        await expectLater(call(baseUrl), throwsA(equals(exception)));
        verify(mockDatasource.getLinagoraEcosystem(baseUrl)).called(1);
        verifyNoMoreInteractions(mockDatasource);
      },
    );
  });
}
