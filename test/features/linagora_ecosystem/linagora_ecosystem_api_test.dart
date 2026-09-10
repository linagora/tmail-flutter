import 'package:core/data/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/network/linagora_ecosystem_api.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/linagora_ecosystem_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';

class _StubDioClient extends DioClient {
  final dynamic response;

  _StubDioClient(this.response) : super(Dio());

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async => response;
}

void main() {
  group('LinagoraEcosystemApi.getLinagoraEcosystem', () {
    const paywallUrlTemplate =
        'https://domain.tld/paywall?email={localPart}';
    final validResponses = [
      (
        description: 'map response',
        response: {'paywallUrlTemplate': paywallUrlTemplate},
      ),
      (
        description: 'JSON string response',
        response:
            '{"paywallUrlTemplate":"https://domain.tld/paywall?email={localPart}"}',
      ),
    ];

    for (final validResponse in validResponses) {
      test('should return the ecosystem for a valid '
          '${validResponse.description}', () async {
        final api = LinagoraEcosystemApi(
          _StubDioClient(validResponse.response),
        );

        final result = await api.getLinagoraEcosystem(
          'https://mail.domain.tld',
        );

        expect(result.paywallUrlTemplate, paywallUrlTemplate);
      });
    }

    final missingPaywallCases = [
      (
        description: 'missing property',
        response: {'scribePromptUrl': 'https://domain.tld/scribe'},
      ),
      (
        description: 'blank property',
        response: {'paywallUrlTemplate': '   '},
      ),
      (
        description: 'property with an invalid type',
        response: {
          'paywallUrlTemplate': {'url': 'invalid'},
        },
      ),
    ];

    for (final missingPaywallCase in missingPaywallCases) {
      test('should keep paywall unavailable for '
          '${missingPaywallCase.description}', () async {
        final api = LinagoraEcosystemApi(
          _StubDioClient(missingPaywallCase.response),
        );

        final result = await api.getLinagoraEcosystem(
          'https://mail.domain.tld',
        );

        expect(result.paywallUrlTemplate, isNull);
      });
    }

    final unsupportedResponses = [
      (description: 'list response', response: <dynamic>[]),
      (description: 'stringified list response', response: '[]'),
    ];

    for (final unsupportedResponse in unsupportedResponses) {
      test('should throw NotFoundLinagoraEcosystem for '
          '${unsupportedResponse.description}', () async {
        final api = LinagoraEcosystemApi(
          _StubDioClient(unsupportedResponse.response),
        );

        await expectLater(
          api.getLinagoraEcosystem('https://mail.domain.tld'),
          throwsA(isA<NotFoundLinagoraEcosystem>()),
        );
      });
    }
  });
}
