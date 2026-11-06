import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_account_verifier.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_data.dart';

class _RedirectedSessionAdapter implements HttpClientAdapter {
  _RedirectedSessionAdapter(this.location);

  final String location;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode({'username': 'alice@twake.app'}),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
    isRedirect: true,
  )..redirects = [RedirectRecord(302, 'GET', Uri.parse(location))];

  @override
  void close({bool force = false}) {}
}

void main() {
  final link = OpenAppDeepLinkData(
    registrationUrl: 'https://sign-up.twake.app',
    jmapUrl: 'https://jmap.twake.app',
    username: 'alice@twake.app',
    accessToken: 'link-token',
  );

  late Dio dio;
  late DioAdapter adapter;
  late DeepLinkAccountVerifier verifier;

  setUp(() {
    dio = Dio();
    adapter = DioAdapter(dio: dio);
    verifier = DeepLinkAccountVerifier(createDio: () => dio);
  });

  test(
    'SHOULD return the session username, not the names of the other accounts, '
    'WHEN the server accepts the link token',
    () async {
      adapter.onGet(
        '/.well-known/jmap',
        (server) => server.reply(200, {
          'username': 'alice@twake.app',
          'accounts': {
            'a1': {'name': 'personal@twake.app', 'isPersonal': true},
            'a2': {'name': 'team@twake.app', 'isPersonal': false},
          },
        }),
        headers: {'Authorization': 'Bearer link-token'},
      );

      final username = await verifier.getAccountUsername(link);

      expect(username, 'alice@twake.app');
      expect(dio.options.baseUrl, 'https://jmap.twake.app');
    },
  );

  test('SHOULD throw WHEN the session has no username', () async {
    adapter.onGet('/.well-known/jmap', (server) => server.reply(200, {'accounts': {}}));

    expect(() => verifier.getAccountUsername(link), throwsA(isA<StateError>()));
  });

  test('SHOULD throw WHEN the session username is blank', () async {
    adapter.onGet(
      '/.well-known/jmap',
      (server) => server.reply(200, {'username': '   '}),
    );

    expect(() => verifier.getAccountUsername(link), throwsA(isA<StateError>()));
  });

  test('SHOULD throw WHEN the session username is not a string', () async {
    adapter.onGet(
      '/.well-known/jmap',
      (server) => server.reply(200, {'username': 42}),
    );

    expect(() => verifier.getAccountUsername(link), throwsA(isA<StateError>()));
  });

  test('SHOULD throw WHEN the server refuses the link token', () async {
    adapter.onGet(
      '/.well-known/jmap',
      (server) => server.reply(401, {'error': 'unauthorized'}),
    );

    expect(() => verifier.getAccountUsername(link), throwsA(isA<DioException>()));
  });

  test(
    'SHOULD return the session username WHEN the session is answered after a redirect on the same host',
    () async {
      dio.httpClientAdapter = _RedirectedSessionAdapter('https://jmap.twake.app/jmap/session');

      expect(await verifier.getAccountUsername(link), 'alice@twake.app');
    },
  );

  test(
    'SHOULD throw WHEN the session is answered after a redirect to a host that is not allowed',
    () async {
      dio.httpClientAdapter = _RedirectedSessionAdapter('https://evil.example/jmap/session');

      expect(() => verifier.getAccountUsername(link), throwsA(isA<StateError>()));
    },
  );
}
