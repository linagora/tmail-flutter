import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/home/data/datasource_impl/session_datasource_impl.dart';
import 'package:tmail_ui_user/features/home/data/network/session_api.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/remote_exception_thrower.dart';

class _FakeSession implements Session {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSessionAPI implements SessionAPI {
  _FakeSessionAPI(this._answers);

  final List<Object> _answers;
  int calls = 0;

  @override
  Future<Session> getSession({converters}) async {
    final answer = _answers[calls++];
    if (answer is Session) return answer;
    throw answer;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DioException _transportError(Object cause) => DioException(
      requestOptions: RequestOptions(path: '/jmap/session'),
      type: DioExceptionType.unknown,
      error: cause,
    );

DioException _unauthorized() => DioException(
      requestOptions: RequestOptions(path: '/jmap/session'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/jmap/session'),
        statusCode: 401,
      ),
    );

/// Asks the data source for the session while the API answers [answers] in
/// order, and returns what it got: the session or the error, and the calls.
({Object? outcome, int calls}) _getSession(List<Object> answers) {
  final api = _FakeSessionAPI(answers);
  Object? outcome;
  fakeAsync((async) {
    SessionDataSourceImpl(api, RemoteExceptionThrower())
        .getSession()
        .then<void>((session) => outcome = session)
        .catchError((Object error) => outcome = error);
    async.flushTimers();
  });
  return (outcome: outcome, calls: api.calls);
}

void main() {
  final session = _FakeSession();

  test(
    'WHEN the session request fails once on a socket error\n'
    'THEN it is sent again and its result is returned',
    () {
      final result = _getSession([
        _transportError(const SocketException('Bad file descriptor')),
        session,
      ]);

      expect(result.outcome, same(session));
      expect(result.calls, 2);
    },
  );

  test(
    'WHEN the session request fails twice on a connection error\n'
    'THEN the second error is thrown',
    () {
      const cause = HttpException('Connection closed before full header was received');
      final result = _getSession([_transportError(cause), _transportError(cause)]);

      expect(result.outcome, isA<ConnectionError>());
      expect(result.calls, 2);
    },
  );

  test(
    'WHEN the session request is rejected by the server\n'
    'THEN it is not sent again',
    () {
      final result = _getSession([_unauthorized()]);

      expect(result.outcome, isA<BadCredentialsException>());
      expect(result.calls, 1);
    },
  );
}
