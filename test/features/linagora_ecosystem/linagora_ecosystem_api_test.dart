import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/network/linagora_ecosystem_api.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/linagora_ecosystem_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';

import 'linagora_ecosystem_api_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late LinagoraEcosystemApi api;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    api = LinagoraEcosystemApi(mockDioClient);
  });

  const baseUrl = 'https://example.com';

  final validJsonMap = {
    'id': 'ecosystem_1',
    'name': 'My Ecosystem',
    'properties': {}
  };

  group('LinagoraEcosystemApi', () {
    group('getLinagoraEcosystem', () {
      test('should return LinagoraEcosystem when Dio returns a valid Map',
          () async {
        // Arrange
        when(mockDioClient.get(any)).thenAnswer((_) async => validJsonMap);

        // Act
        final result = await api.getLinagoraEcosystem(baseUrl);

        // Assert
        expect(result, isA<LinagoraEcosystem>());
        verify(mockDioClient.get(any)).called(1);
      });

      test(
          'should return LinagoraEcosystem when Dio returns a valid JSON String',
          () async {
        // Arrange
        final jsonString = jsonEncode(validJsonMap);
        when(mockDioClient.get(any)).thenAnswer((_) async => jsonString);

        // Act
        final result = await api.getLinagoraEcosystem(baseUrl);

        // Assert
        expect(result, isA<LinagoraEcosystem>());
        verify(mockDioClient.get(any)).called(1);
      });

      test(
          'should throw NotFoundLinagoraEcosystem when Dio returns invalid type (e.g. List)',
          () async {
        // Arrange
        when(mockDioClient.get(any)).thenAnswer((_) async => []);

        // Act & Assert
        await expectLater(
          api.getLinagoraEcosystem(baseUrl),
          throwsA(isA<NotFoundLinagoraEcosystem>()),
        );
      });
    });

    group('getPaywallUrl', () {
      test('should return PaywallUrlPattern when property exists', () async {
        // Arrange
        final paywallJsonMap = {
          'paywallUrlTemplate': 'https://paywall.example.com',
        };

        when(mockDioClient.get(any)).thenAnswer((_) async => paywallJsonMap);

        // Act
        final result = await api.getPaywallUrl(baseUrl);

        // Assert
        expect(result, isA<PaywallUrlPattern>());
        expect(result.pattern, 'https://paywall.example.com');
      });

      test('should throw NotFoundPaywallUrl when property is missing',
          () async {
        // Arrange
        final emptyPropsMap = {'properties': {}};

        when(mockDioClient.get(any)).thenAnswer((_) async => emptyPropsMap);

        // Act & Assert
        await expectLater(
          api.getPaywallUrl(baseUrl),
          throwsA(isA<NotFoundPaywallUrl>()),
        );
      });
    });
  });
}
