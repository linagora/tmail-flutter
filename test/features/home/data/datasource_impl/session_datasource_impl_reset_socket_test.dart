import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/http/http_client.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/home/data/datasource_impl/session_datasource_impl.dart';
import 'package:tmail_ui_user/features/home/data/network/session_api.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/remote_exception_thrower.dart';

const _sessionBody = {
  'capabilities': <String, dynamic>{},
  'accounts': <String, dynamic>{},
  'primaryAccounts': <String, dynamic>{},
  'username': 'alice@example.com',
  'apiUrl': 'http://localhost/jmap',
  'downloadUrl': 'http://localhost/download/{accountId}/{blobId}/?type={type}&name={name}',
  'uploadUrl': 'http://localhost/upload/{accountId}',
  'eventSourceUrl': 'http://localhost/eventSource?types={types}&closeAfter={closeafter}&ping={ping}',
  'state': 'state-1',
};

/// Answers with the session, except for the first [resetCount] requests: their
/// connection is closed before any header, like a socket iOS closed while the
/// app was suspended.
Future<HttpServer> _startServer({
  required int resetCount,
  required void Function() onRequest,
}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  var served = 0;
  server.listen((request) async {
    onRequest();
    if (served++ < resetCount) {
      (await request.response.detachSocket(writeHeaders: false)).destroy();
      return;
    }
    request.response
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(_sessionBody));
    await request.response.close();
  });
  return server;
}

SessionDataSourceImpl _dataSourceOf(HttpServer server) {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:${server.port}'));
  return SessionDataSourceImpl(
    SessionAPI(jmap.HttpClient(dio)),
    RemoteExceptionThrower(),
  );
}

void main() {
  group('getSession over a real socket the server closes', () {
    late HttpServer server;
    late int requestCount;

    setUp(() => requestCount = 0);

    tearDown(() => server.close(force: true));

    test('Should return the session WHEN only the first connection is closed', () async {
      server = await _startServer(resetCount: 1, onRequest: () => requestCount++);

      final session = await _dataSourceOf(server).getSession();

      expect(session, isA<Session>());
      expect(requestCount, 2);
    });

    test('Should send the request only twice WHEN every connection is closed', () async {
      server = await _startServer(resetCount: 100, onRequest: () => requestCount++);

      await expectLater(
        _dataSourceOf(server).getSession(),
        throwsA(anyOf(isA<ConnectionError>(), isA<SocketError>())),
      );

      expect(requestCount, 2);
    });
  });
}
