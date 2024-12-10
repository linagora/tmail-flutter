import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_data.dart';
import 'package:tmail_ui_user/main/deep_links/deep_links_manager.dart';

void main() {
  final deepLinkManager = DeepLinksManager();

  group('DeepLinksManager::parseDeepLink::test', () {
    test('Valid deep link with multiple query parameters', () {
      const deepLink = 'twake.mail://openApp?access_token=ey123456&refresh_token=ey7890&id_token=token&expires_in=3600&username=user@example.com';
      final expectedData = DeepLinkData(
        action: 'openapp',
        accessToken: 'ey123456',
        refreshToken: 'ey7890',
        idToken: 'token',
        expiresIn: 3600,
        username: 'user@example.com',
      );
      final deepLinkData = deepLinkManager.parseDeepLink(deepLink);

      expect(deepLinkData, equals(expectedData));
    });

    test('Deep link with no query parameters', () {
      const deepLink = 'twake.mail://openApp';
      final expectedData = DeepLinkData(action: 'openapp');
      final deepLinkData = deepLinkManager.parseDeepLink(deepLink);

      expect(deepLinkData, expectedData);
    });

    test('Deep link with one query parameter', () {
      const deepLink = 'twake.mail://openApp?access_token=ey123456';
      final expectedData = DeepLinkData(action: 'openapp', accessToken: 'ey123456',);
      final deepLinkData = deepLinkManager.parseDeepLink(deepLink);

      expect(deepLinkData, equals(expectedData));
    });

    test('Invalid deep link format', () {
      const deepLink = 'Invalid link: invalid';
      final deepLinkData = deepLinkManager.parseDeepLink(deepLink);
      expect(deepLinkData, isNull);
    });
  });
}