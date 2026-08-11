import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/mobile_refresh_token_error_classifier.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/oauth_authorization_error.dart';

void main() {
  late MobileRefreshTokenErrorClassifier classifier;

  setUp(() => classifier = MobileRefreshTokenErrorClassifier());

  group('MobileRefreshTokenErrorClassifier::isServerRejection', () {
    // The native refresh reports a 400 from the token endpoint as an
    // OAuthAuthorizationError carrying the RFC 6749 code from the body.
    for (final code in const [
      'invalid_grant',
      'invalid_client',
      'invalid_request',
      'invalid_scope',
      'unauthorized_client',
      'unsupported_grant_type',
    ]) {
      test('returns true for $code', () {
        expect(
          classifier.isServerRejection(OAuthAuthorizationError(error: code)),
          isTrue,
        );
      });
    }

    test('returns true for token_failed wrapping an RFC 6749 code', () {
      expect(
        classifier.isServerRejection(const OAuthAuthorizationError(
          error: 'token_failed',
          errorDescription: 'invalid_grant',
        )),
        isTrue,
      );
    });

    test('returns false for token_failed with a non-RFC description', () {
      expect(
        classifier.isServerRejection(const OAuthAuthorizationError(
          error: 'token_failed',
          errorDescription: 'Network is unreachable',
        )),
        isFalse,
      );
    });

    test('returns false for token_failed with no description', () {
      expect(
        classifier.isServerRejection(
          const OAuthAuthorizationError(error: 'token_failed'),
        ),
        isFalse,
      );
    });

    // Transient SSO failures must keep the session — a flaky mobile connection
    // may not sign the user out.
    test('returns false for ServerError', () {
      expect(classifier.isServerRejection(const ServerError()), isFalse);
    });

    test('returns false for TemporarilyUnavailable', () {
      expect(
        classifier.isServerRejection(const TemporarilyUnavailable()),
        isFalse,
      );
    });

    test('returns false for an unknown OAuth code', () {
      expect(
        classifier.isServerRejection(
          const OAuthAuthorizationError(error: 'custom_provider_error'),
        ),
        isFalse,
      );
    });

    // Shared behaviour inherited from the base classifier.
    test('returns true for AccessTokenInvalidException', () {
      expect(
        classifier.isServerRejection(AccessTokenInvalidException()),
        isTrue,
      );
    });

    for (final statusCode in const [400, 401]) {
      test('returns true for DioException $statusCode', () {
        expect(classifier.isServerRejection(_dioError(statusCode)), isTrue);
      });
    }

    for (final statusCode in const [500, 503]) {
      test('returns false for DioException $statusCode', () {
        expect(classifier.isServerRejection(_dioError(statusCode)), isFalse);
      });
    }

    test('returns false for DioException with no response', () {
      expect(
        classifier.isServerRejection(DioException(
          requestOptions: RequestOptions(path: '/token'),
          type: DioExceptionType.connectionError,
        )),
        isFalse,
      );
    });

    // The web plugin's error shape must never be classified by mobile.
    test('returns false for the web plugin ArgumentError shape', () {
      expect(
        classifier.isServerRejection(ArgumentError(
          'Failed to get token: [error: invalid_grant, description: revoked]',
        )),
        isFalse,
      );
    });

    test('returns false for a generic Exception', () {
      expect(classifier.isServerRejection(Exception('boom')), isFalse);
    });
  });

  group('MobileRefreshTokenErrorClassifier::buildSentryExtras', () {
    test('tags a rejection and exposes the OAuth code and description', () {
      expect(
        classifier.buildSentryExtras(const OAuthAuthorizationError(
          error: 'invalid_grant',
          errorDescription: 'The refresh token has been revoked',
        )),
        {
          'auth_error_type': 'token_endpoint_oauth_rejected',
          'oauth_error_code': 'invalid_grant',
          'oauth_error_description': 'The refresh token has been revoked',
        },
      );
    });

    test('tags a kept session and still exposes the OAuth code', () {
      expect(
        classifier.buildSentryExtras(const ServerError()),
        {
          'auth_error_type': 'token_endpoint_oauth_unknown_error',
          'oauth_error_code': 'server_error',
          'oauth_error_description': 'unknown',
        },
      );
    });

    test('omits OAuth fields for a non-OAuth error', () {
      expect(
        classifier.buildSentryExtras(_dioError(503)),
        {'auth_error_type': 'token_endpoint_oauth_unknown_error'},
      );
    });
  });
}

DioException _dioError(int statusCode) => DioException(
      requestOptions: RequestOptions(path: '/token'),
      response: Response(
        statusCode: statusCode,
        requestOptions: RequestOptions(path: '/token'),
      ),
      type: DioExceptionType.badResponse,
    );
