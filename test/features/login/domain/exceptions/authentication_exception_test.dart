import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

void main() {
  group('OidcConfigurationException', () {
    test('should create exception with message only', () {
      // arrange & act
      final exception = OidcConfigurationException('Test error message');

      // assert
      expect(exception.message, 'Test error message');
      expect(exception.technicalDetails, isNull);
    });

    test('should create exception with message and technical details', () {
      // arrange & act
      final exception = OidcConfigurationException(
        'Test error message',
        technicalDetails: 'some_technical_detail',
      );

      // assert
      expect(exception.message, 'Test error message');
      expect(exception.technicalDetails, 'some_technical_detail');
    });

    test('toString should include message without technical details', () {
      // arrange
      final exception = OidcConfigurationException('Test error');

      // act
      final result = exception.toString();

      // assert
      expect(result, 'OidcConfigurationException: Test error');
    });

    test('toString should include message and technical details', () {
      // arrange
      final exception = OidcConfigurationException(
        'Test error',
        technicalDetails: 'detail_info',
      );

      // act
      final result = exception.toString();

      // assert
      expect(result, 'OidcConfigurationException: Test error (detail_info)');
    });
  });

  group('MissingEndSessionEndpointException', () {
    test('should have correct message', () {
      // arrange & act
      final exception = MissingEndSessionEndpointException();

      // assert
      expect(exception.message, 'OIDC logout endpoint not configured');
    });

    test('should have correct technical details', () {
      // arrange & act
      final exception = MissingEndSessionEndpointException();

      // assert
      expect(
        exception.technicalDetails,
        'end_session_endpoint missing from OIDC discovery',
      );
    });

    test('should be instance of OidcConfigurationException', () {
      // arrange & act
      final exception = MissingEndSessionEndpointException();

      // assert
      expect(exception, isA<OidcConfigurationException>());
    });
  });

  group('MissingAuthorizationEndpointException', () {
    test('should have correct message', () {
      // arrange & act
      final exception = MissingAuthorizationEndpointException();

      // assert
      expect(exception.message, 'OIDC authorization endpoint not configured');
    });

    test('should have correct technical details', () {
      // arrange & act
      final exception = MissingAuthorizationEndpointException();

      // assert
      expect(
        exception.technicalDetails,
        'authorization_endpoint missing from OIDC discovery',
      );
    });

    test('should be instance of OidcConfigurationException', () {
      // arrange & act
      final exception = MissingAuthorizationEndpointException();

      // assert
      expect(exception, isA<OidcConfigurationException>());
    });
  });

  group('MissingTokenEndpointException', () {
    test('should have correct message', () {
      // arrange & act
      final exception = MissingTokenEndpointException();

      // assert
      expect(exception.message, 'OIDC token endpoint not configured');
    });

    test('should have correct technical details', () {
      // arrange & act
      final exception = MissingTokenEndpointException();

      // assert
      expect(
        exception.technicalDetails,
        'token_endpoint missing from OIDC discovery',
      );
    });

    test('should be instance of OidcConfigurationException', () {
      // arrange & act
      final exception = MissingTokenEndpointException();

      // assert
      expect(exception, isA<OidcConfigurationException>());
    });
  });

  group('OidcDiscoveryFailedException', () {
    test('should have correct message', () {
      // arrange & act
      final exception = OidcDiscoveryFailedException('connection timeout');

      // assert
      expect(exception.message, 'Failed to retrieve OIDC configuration');
    });

    test('should store provided technical details', () {
      // arrange & act
      final exception = OidcDiscoveryFailedException('connection timeout');

      // assert
      expect(exception.technicalDetails, 'connection timeout');
    });

    test('should be instance of OidcConfigurationException', () {
      // arrange & act
      final exception = OidcDiscoveryFailedException('error');

      // assert
      expect(exception, isA<OidcConfigurationException>());
    });
  });
}
