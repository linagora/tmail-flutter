import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_action_type.dart';
import 'package:tmail_ui_user/main/deep_links/deep_links_manager.dart';

void main() {
  final deepLinkManager = DeepLinksManager();

  group('DeepLinksManager::test', () {
    group('parseDeepLink::test', () {
      test('SHOULD returns correct DeepLinkData for valid openApp deep link', () {
        const url = 'twake://openApp/some-data';
        final result = deepLinkManager.parseDeepLink(url);

        expect(result, isNotNull);
        expect(result?.actionType, DeepLinkActionType.openApp);
      });

      test('SHOULD returns DeepLinkData with unknown action for unhandled action', () {
        const url = 'twake://unknownAction/some-data';
        final result = deepLinkManager.parseDeepLink(url);

        expect(result, isNotNull);
        expect(result?.actionType, DeepLinkActionType.unknown);
      });

      test('SHOULD returns null for malformed URL', () {
        const url = 'Invalid link: invalid';
        final result = deepLinkManager.parseDeepLink(url);

        expect(result, isNull);
      });

      test('SHOULD returns null for exception during parsing', () {
        const url = 'twake://malformedurl%';
        final result = deepLinkManager.parseDeepLink(url);

        expect(result, isNull);
      });
    });

    group('parseOpenAppDeepLink::test', () {
      test('SHOULD returns OpenAppDeepLinkData with all valid parameters', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&refresh_token=refresh123'
              '&id_token=id123'
              '&expires_in=3600'
              '&username=dXNlcg=='
              '&registrationUrl=https://registration.url'
              '&jmapUrl=https://jmap.url',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.accessToken, 'token123');
        expect(result?.refreshToken, 'refresh123');
        expect(result?.idToken, 'id123');
        expect(result?.expiresIn, 3600);
        expect(result?.username, 'user');
        expect(result?.registrationUrl, 'https://registration.url');
        expect(result?.jmapUrl, 'https://jmap.url');
        expect(result?.isValidAuthentication(), isTrue);
      });

      test('SHOULD returns OpenAppDeepLinkData with missing optional parameters', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&username=user@example.com'
              '&registrationUrl=https://registration.url'
              '&jmapUrl=https://jmap.url',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.accessToken, 'token123');
        expect(result?.refreshToken, isNull);
        expect(result?.idToken, isNull);
        expect(result?.expiresIn, isNull);
        expect(result?.username, 'user@example.com');
        expect(result?.registrationUrl, 'https://registration.url');
        expect(result?.jmapUrl, 'https://jmap.url');
        expect(result?.isValidAuthentication(), isTrue);
      });


      test('SHOULD returns OpenAppDeepLinkData with invalid expires_in', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&expires_in=not_a_number'
              '&registrationUrl=https://registration.url'
              '&jmapUrl=https://jmap.url',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.expiresIn, isNull);
      });

      test('SHOULD returns OpenAppDeepLinkData with origin username if Base64 decoding fails', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&username=invalid_base64'
              '&registrationUrl=https://registration.url'
              '&jmapUrl=https://jmap.url',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.username, 'invalid_base64');
      });

      test('SHOULD returns OpenAppDeepLinkData with jmapUrl contains sub-path and port', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&refresh_token=refresh123'
              '&id_token=id123'
              '&expires_in=3600'
              '&username=dXNlcg=='
              '&registrationUrl=https://registration.url'
              '&jmapUrl=https://jmap.url:1000/jmap',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.jmapUrl, 'https://jmap.url:1000/jmap');
      });

      test('SHOULD returns OpenAppDeepLinkData with registrationUrl contains sub-path and port', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&refresh_token=refresh123'
              '&id_token=id123'
              '&expires_in=3600'
              '&username=dXNlcg=='
              '&registrationUrl=https://registration.url:1000/register'
              '&jmapUrl=https://jmap.url',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.registrationUrl, 'https://registration.url:1000/register');
      });
    });
  });
}