import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/web_refresh_token_error_classifier.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

void main() {
  late WebRefreshTokenErrorClassifier classifier;

  setUp(() {
    classifier = WebRefreshTokenErrorClassifier();
  });

  group('WebRefreshTokenErrorClassifier::isServerRejection', () {
    group('AccessTokenInvalidException', () {
      test('returns true', () {
        expect(classifier.isServerRejection(AccessTokenInvalidException()), isTrue);
      });
    });

    group('DioException', () {
      DioException dioBadResponse(int statusCode) => DioException(
            requestOptions: RequestOptions(),
            response: Response(requestOptions: RequestOptions(), statusCode: statusCode),
            type: DioExceptionType.badResponse,
          );

      test('returns true for 400', () {
        expect(classifier.isServerRejection(dioBadResponse(400)), isTrue);
      });

      test('returns true for 401', () {
        expect(classifier.isServerRejection(dioBadResponse(401)), isTrue);
      });

      test('returns false for 500', () {
        expect(classifier.isServerRejection(dioBadResponse(500)), isFalse);
      });

      test('returns false for 503', () {
        expect(classifier.isServerRejection(dioBadResponse(503)), isFalse);
      });

      test('returns false when no response', () {
        final error = DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        );
        expect(classifier.isServerRejection(error), isFalse);
      });
    });

    group('ArgumentError — RFC 6749 §5.2 standard codes', () {
      ArgumentError appAuthError(String code, {String desc = 'some description'}) =>
          ArgumentError('Invalid argument(s): Failed to get token: [error: $code, description: $desc]');

      test('returns true for invalid_grant', () {
        expect(classifier.isServerRejection(appAuthError('invalid_grant')), isTrue);
      });

      test('returns true for invalid_client', () {
        expect(classifier.isServerRejection(appAuthError('invalid_client')), isTrue);
      });

      test('returns true for invalid_request', () {
        expect(classifier.isServerRejection(appAuthError('invalid_request')), isTrue);
      });

      test('returns true for invalid_scope', () {
        expect(classifier.isServerRejection(appAuthError('invalid_scope')), isTrue);
      });

      test('returns true for unauthorized_client', () {
        expect(classifier.isServerRejection(appAuthError('unauthorized_client')), isTrue);
      });
    });

    group('ArgumentError — non-standard / unknown codes', () {
      ArgumentError appAuthError(String code, {String desc = 'some description'}) =>
          ArgumentError('Invalid argument(s): Failed to get token: [error: $code, description: $desc]');

      test('returns false for token_failed with invalid_grant in description', () {
        // "token_failed" is not RFC 6749; unknown HTTP status — keep session
        expect(
          classifier.isServerRejection(appAuthError('token_failed', desc: 'invalid_grant')),
          isFalse,
        );
      });

      test('returns false for token_failed with invalid_request in description', () {
        expect(
          classifier.isServerRejection(appAuthError('token_failed', desc: 'invalid_request')),
          isFalse,
        );
      });

      test('returns false for token_failed with empty description', () {
        expect(classifier.isServerRejection(appAuthError('token_failed', desc: '')), isFalse);
      });
    });

    group('ArgumentError — unrelated errors', () {
      test('returns false for Invalid or corrupted pad block', () {
        expect(
          classifier.isServerRejection(ArgumentError('Invalid or corrupted pad block')),
          isFalse,
        );
      });

      test('returns false for ArgumentError with null message', () {
        expect(classifier.isServerRejection(ArgumentError(null)), isFalse);
      });
    });

    group('other error types', () {
      test('returns false for generic Exception', () {
        expect(classifier.isServerRejection(Exception('boom')), isFalse);
      });

      test('returns false for StateError', () {
        expect(classifier.isServerRejection(StateError('bad state')), isFalse);
      });
    });
  });

  group('WebRefreshTokenErrorClassifier::buildSentryExtras', () {
    test('uses web_server_rejected_refresh for AccessTokenInvalidException', () {
      final extras = classifier.buildSentryExtras(AccessTokenInvalidException());
      expect(extras['auth_error_type'], equals('web_server_rejected_refresh'));
    });

    test('uses web_server_rejected_refresh for DioException 401', () {
      final error = DioException(
        requestOptions: RequestOptions(),
        response: Response(requestOptions: RequestOptions(), statusCode: 401),
        type: DioExceptionType.badResponse,
      );
      final extras = classifier.buildSentryExtras(error);
      expect(extras['auth_error_type'], equals('web_server_rejected_refresh'));
    });

    test('uses web_token_unknown_error for DioException 503', () {
      final error = DioException(
        requestOptions: RequestOptions(),
        response: Response(requestOptions: RequestOptions(), statusCode: 503),
        type: DioExceptionType.badResponse,
      );
      final extras = classifier.buildSentryExtras(error);
      expect(extras['auth_error_type'], equals('web_token_unknown_error'));
    });

    group('ArgumentError oauth fields', () {
      test('parses code and description for invalid_grant', () {
        final error = ArgumentError(
          'Invalid argument(s): Failed to get token: [error: invalid_grant, description: Token has expired]',
        );
        final extras = classifier.buildSentryExtras(error);
        expect(extras['auth_error_type'], equals('web_server_rejected_refresh'));
        expect(extras['oauth_error_code'], equals('invalid_grant'));
        expect(extras['oauth_error_description'], equals('Token has expired'));
      });

      test('parses code and description for token_failed (unknown)', () {
        final error = ArgumentError(
          'Invalid argument(s): Failed to get token: [error: token_failed, description: invalid_request]',
        );
        final extras = classifier.buildSentryExtras(error);
        expect(extras['auth_error_type'], equals('web_token_unknown_error'));
        expect(extras['oauth_error_code'], equals('token_failed'));
        expect(extras['oauth_error_description'], equals('invalid_request'));
      });

      test('returns unknown for unrecognized message format', () {
        final error = ArgumentError('Invalid or corrupted pad block');
        final extras = classifier.buildSentryExtras(error);
        expect(extras['auth_error_type'], equals('web_token_unknown_error'));
        expect(extras['oauth_error_code'], equals('unknown'));
        expect(extras['oauth_error_description'], equals('unknown'));
      });

      test('returns unknown when message is null', () {
        final extras = classifier.buildSentryExtras(ArgumentError(null));
        expect(extras['oauth_error_code'], equals('unknown'));
        expect(extras['oauth_error_description'], equals('unknown'));
      });
    });
  });
}
