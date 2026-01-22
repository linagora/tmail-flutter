import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/linagora_ecosystem_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/network/linagora_ecosystem_api.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

import 'linagora_ecosystem_datasource_impl_test.mocks.dart';

@GenerateMocks([LinagoraEcosystemApi, ExceptionThrower, LinagoraEcosystem])
void main() {
  late LinagoraEcosystemDatasourceImpl datasource;
  late MockLinagoraEcosystemApi mockApi;
  late MockExceptionThrower mockExceptionThrower;

  setUp(() {
    mockApi = MockLinagoraEcosystemApi();
    mockExceptionThrower = MockExceptionThrower();
    datasource = LinagoraEcosystemDatasourceImpl(mockApi, mockExceptionThrower);
  });

  const baseUrl = 'https://example.com';

  group('LinagoraEcosystemDatasourceImpl', () {
    test(
      'should return LinagoraEcosystem when API call is successful',
      () async {
        // Arrange
        final ecosystem = MockLinagoraEcosystem();

        when(mockApi.getLinagoraEcosystem(any))
            .thenAnswer((_) async => ecosystem);

        // Act
        final result = await datasource.getLinagoraEcosystem(baseUrl);

        // Assert
        expect(result, equals(ecosystem));
        verify(mockApi.getLinagoraEcosystem(baseUrl)).called(1);
        verifyZeroInteractions(mockExceptionThrower);
      },
    );

    test(
      'should delegate to ExceptionThrower when API throws an error',
      () async {
        // Arrange
        final apiError = Exception('API Error');

        when(mockApi.getLinagoraEcosystem(any))
            .thenAnswer((_) async => throw apiError);

        when(mockExceptionThrower.throwException(any, any))
            .thenAnswer((realInvocation) => throw apiError);

        // Act
        final call = datasource.getLinagoraEcosystem;

        // Assert
        await expectLater(call(baseUrl), throwsA(equals(apiError)));

        verify(mockApi.getLinagoraEcosystem(baseUrl)).called(1);

        verify(mockExceptionThrower.throwException(any, any)).called(1);
      },
    );
  });
}
