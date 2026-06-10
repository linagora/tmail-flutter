import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/dio_no_response_error_handler.dart';

void main() {
  late DioNoResponseErrorHandler handler;

  setUp(() {
    handler = DioNoResponseErrorHandler();
  });

  group('DioNoResponseErrorHandler', () {
    test(
      'WHEN DioException type=connectionError\n'
      'THEN throws ConnectionError',
      () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/jmap'),
          type: DioExceptionType.connectionError,
          message: 'Connection refused',
        );

        expect(
          () => handler.handle(error),
          throwsA(isA<ConnectionError>()),
        );
      },
    );

    test(
      'WHEN DioException type=connectionTimeout\n'
      'THEN throws ConnectionTimeout',
      () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/jmap'),
          type: DioExceptionType.connectionTimeout,
        );

        expect(
          () => handler.handle(error),
          throwsA(isA<ConnectionTimeout>()),
        );
      },
    );

    test(
      'WHEN DioException type=unknown with SocketException\n'
      'THEN throws SocketError',
      () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/jmap'),
          type: DioExceptionType.unknown,
          error: const SocketException('Connection refused'),
        );

        expect(
          () => handler.handle(error),
          throwsA(isA<SocketError>()),
        );
      },
    );

    test(
      'WHEN DioException type=unknown with HandshakeException\n'
      'THEN throws ConnectionError (not logout, not Sentry error)\n'
      'AND OIDC session is preserved (no forced logout path)',
      () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/jmap'),
          type: DioExceptionType.unknown,
          error: const HandshakeException('Connection terminated during handshake'),
        );

        expect(
          () => handler.handle(error),
          throwsA(
            isA<ConnectionError>().having(
              (e) => e.message,
              'message',
              contains('Connection terminated during handshake'),
            ),
          ),
        );
      },
    );
  });
}
