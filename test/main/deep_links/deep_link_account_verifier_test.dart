import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_account_verifier.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_data.dart';

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
    'SHOULD return the session username then the account names '
    'WHEN the server accepts the link token',
    () async {
      adapter.onGet(
        '/.well-known/jmap',
        (server) => server.reply(200, {
          'username': 'alice@twake.app',
          'accounts': {
            'a1': {'name': 'alice@twake.app', 'isPersonal': true},
            'a2': {'name': 'team@twake.app', 'isPersonal': false},
          },
        }),
        headers: {'Authorization': 'Bearer link-token'},
      );

      final identities = await verifier.getAccountIdentities(link);

      expect(identities, ['alice@twake.app', 'alice@twake.app', 'team@twake.app']);
      expect(dio.options.baseUrl, 'https://jmap.twake.app');
    },
  );

  test('SHOULD throw WHEN the server refuses the link token', () async {
    adapter.onGet(
      '/.well-known/jmap',
      (server) => server.reply(401, {'error': 'unauthorized'}),
    );

    expect(() => verifier.getAccountIdentities(link), throwsA(isA<DioException>()));
  });
}
