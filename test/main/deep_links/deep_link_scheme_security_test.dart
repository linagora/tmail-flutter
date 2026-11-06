import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_action_type.dart';
import 'package:tmail_ui_user/main/deep_links/deep_links_manager.dart';

void main() {
  final deepLinkManager = DeepLinksManager();

  const signInQuery = '?access_token=token'
      '&username=YWxpY2VAdHdha2UuYXBw'
      '&registrationUrl=https://sign-up.twake.app'
      '&jmapUrl=https://jmap.twake.app';

  group('DeepLinksManager::parseDeepLink scheme', () {
    test('SHOULD read a Twake Mail openApp link as a sign-in link', () {
      final result = deepLinkManager.parseDeepLink('twakemail.mobile://openApp$signInQuery');

      expect(result?.actionType, DeepLinkActionType.openApp);
    });

    // Composing from a mailto link goes through the share intent handler, not
    // here: a real mailto link was never a sign-in link and must stay so.
    for (final mailto in [
      'mailto:bob@corp.example',
      'mailto:bob@corp.example?subject=Hello&body=Hi%20Bob',
      'mailto:?to=bob@corp.example&cc=alice@corp.example',
    ]) {
      test('SHOULD keep the mail link $mailto out of sign-in', () {
        final result = deepLinkManager.parseDeepLink(mailto);

        expect(result?.actionType, DeepLinkActionType.unknown);
      });
    }

    for (final scheme in ['mailto', 'teammail.mobile', 'twake', 'https']) {
      test('SHOULD NOT read a $scheme://openApp link as a sign-in link', () {
        final result = deepLinkManager.parseDeepLink('$scheme://openApp$signInQuery');

        expect(result?.actionType, DeepLinkActionType.unknown);
      });
    }
  });
}
