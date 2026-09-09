import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/api_key_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/api_url_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/default_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/empty_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/mobile_apps_linagora_ecosystem.dart';

const _apiUrl = 'https://example.com/api';
const _logoUrl = 'https://xyz';
const _androidPackageId = 'com.example.android';
const _iosUrlScheme = 'app.scheme';
const _iosAppStoreLink = 'itms-apps://itunes.apple.com/app';

Map<String, dynamic> _iosAndroidAppPayload(String appName) => {
  'appName': appName,
  'logoURL': _logoUrl,
  'androidPackageId': _androidPackageId,
  'iosUrlScheme': _iosUrlScheme,
  'iosAppStoreLink': _iosAppStoreLink,
};

Map<String, dynamic> _androidAppPayload(String appName) => {
  'appName': appName,
  'logoURL': _logoUrl,
  'androidPackageId': _androidPackageId,
};

Map<String, dynamic> _allPropertiesPayload() => {
  'linShareApiUrl': _apiUrl,
  'linToApiUrl': _apiUrl,
  'linToApiKey': 'apiKey',
  'twakeApiUrl': _apiUrl,
  'Twake Drive': {
    'appName': 'Twake Drive',
    'logoURL': _logoUrl,
    'webLink': 'https://abc',
  },
  'mobileApps': <String, dynamic>{
    'Twake Chat': _iosAndroidAppPayload('Twake Chat'),
    'Twake Sync': _androidAppPayload('Twake Sync'),
    'LinShare': _iosAndroidAppPayload('LinShare'),
  },
};

Map<String, dynamic> _someNullPropertiesPayload() {
  final payload = _allPropertiesPayload();
  payload['linToApiUrl'] = null;
  payload['Twake Drive'] = null;
  final mobileApps = payload['mobileApps'] as Map<String, dynamic>;
  mobileApps['Twake Sync'] = null;
  return payload;
}

AppLinagoraEcosystem _iosAndroidApp(String appName) =>
    AppLinagoraEcosystem(
      appName: appName,
      logoURL: _logoUrl,
      androidPackageId: _androidPackageId,
      iosUrlScheme: _iosUrlScheme,
      iosAppStoreLink: _iosAppStoreLink,
    );

LinagoraEcosystem _expectedEcosystem({
  required LinagoraEcosystemProperties linToApiUrl,
  required LinagoraEcosystemProperties twakeDrive,
  required LinagoraEcosystemProperties twakeSync,
}) => LinagoraEcosystem({
  LinagoraEcosystemIdentifier.linShareApiUrl:
      ApiUrlLinagoraEcosystem(_apiUrl),
  LinagoraEcosystemIdentifier.linToApiUrl: linToApiUrl,
  LinagoraEcosystemIdentifier.linToApiKey:
      ApiKeyLinagoraEcosystem('apiKey'),
  LinagoraEcosystemIdentifier.twakeApiUrl: ApiUrlLinagoraEcosystem(_apiUrl),
  LinagoraEcosystemIdentifier.twakeDrive: twakeDrive,
  LinagoraEcosystemIdentifier.mobileApps: MobileAppsLinagoraEcosystem({
    LinagoraEcosystemIdentifier.twakeChat:
        _iosAndroidApp('Twake Chat'),
    LinagoraEcosystemIdentifier.twakeSync: twakeSync,
    LinagoraEcosystemIdentifier.linShare: _iosAndroidApp('LinShare'),
  }),
});

LinagoraEcosystem _expectedAllProperties() => _expectedEcosystem(
  linToApiUrl: ApiUrlLinagoraEcosystem(_apiUrl),
  twakeDrive: AppLinagoraEcosystem(
    appName: 'Twake Drive',
    logoURL: _logoUrl,
    webLink: Uri.parse('https://abc'),
  ),
  twakeSync: AppLinagoraEcosystem(
    appName: 'Twake Sync',
    logoURL: _logoUrl,
    androidPackageId: _androidPackageId,
  ),
);

LinagoraEcosystem _expectedSomeNullProperties() => _expectedEcosystem(
  linToApiUrl: EmptyLinagoraEcosystem(),
  twakeDrive: EmptyLinagoraEcosystem(),
  twakeSync: EmptyLinagoraEcosystem(),
);

Map<String, dynamic> _customPropertiesPayload() => {
  'abc': _apiUrl,
  'custom': 'apiKey',
  'twakeApiUrl': _apiUrl,
  'mobileApps': {
    'Twake Chat': _iosAndroidAppPayload('Twake Chat'),
    'xyz': {
      'appName': 'LinShare',
      'logoURL': _logoUrl,
    },
    'dab': 'test',
  },
};

LinagoraEcosystem _expectedCustomProperties() => LinagoraEcosystem({
  LinagoraEcosystemIdentifier('abc'):
      DefaultLinagoraEcosystem(_apiUrl),
  LinagoraEcosystemIdentifier('custom'):
      DefaultLinagoraEcosystem('apiKey'),
  LinagoraEcosystemIdentifier.twakeApiUrl: ApiUrlLinagoraEcosystem(_apiUrl),
  LinagoraEcosystemIdentifier.mobileApps: MobileAppsLinagoraEcosystem({
    LinagoraEcosystemIdentifier.twakeChat:
        _iosAndroidApp('Twake Chat'),
    LinagoraEcosystemIdentifier('xyz'): AppLinagoraEcosystem(
      appName: 'LinShare',
      logoURL: _logoUrl,
    ),
    LinagoraEcosystemIdentifier('dab'): DefaultLinagoraEcosystem('test'),
  }),
});

void main() {
  group('Deserialize LinagoraEcosystem test', () {
    final deserializeCases = [
      (
        description: 'Should parse correctly when all properties are present',
        payload: _allPropertiesPayload(),
        expected: _expectedAllProperties(),
      ),
      (
        description: 'Should parse correctly when some properties are null',
        payload: _someNullPropertiesPayload(),
        expected: _expectedSomeNullProperties(),
      ),
      (
        description:
            'Should parse correctly when some properties are not default',
        payload: _customPropertiesPayload(),
        expected: _expectedCustomProperties(),
      ),
    ];

    for (final deserializeCase in deserializeCases) {
      test(deserializeCase.description, () {
        expect(
          LinagoraEcosystem.deserialize(deserializeCase.payload),
          equals(deserializeCase.expected),
        );
      });
    }

    test('Should return paywall URL template when configured', () {
      final linagoraEcosystem = LinagoraEcosystem.deserialize({
        'paywallUrlTemplate': 'https://domain.tld/paywall?email={localPart}',
      });

      expect(
        linagoraEcosystem.paywallUrlTemplate,
        'https://domain.tld/paywall?email={localPart}',
      );
    });

    test('Should return null when paywall URL template is missing', () {
      final linagoraEcosystem = LinagoraEcosystem.deserialize({
        'scribePromptUrl': 'https://domain.tld/scribe',
      });

      expect(linagoraEcosystem.paywallUrlTemplate, isNull);
    });

    test('Should return null when paywall URL template is blank', () {
      final linagoraEcosystem = LinagoraEcosystem.deserialize({
        'paywallUrlTemplate': '   ',
      });

      expect(linagoraEcosystem.paywallUrlTemplate, isNull);
    });

    test('Should trim paywall URL template', () {
      final linagoraEcosystem = LinagoraEcosystem.deserialize({
        'paywallUrlTemplate': '  https://domain.tld/paywall  ',
      });

      expect(
        linagoraEcosystem.paywallUrlTemplate,
        'https://domain.tld/paywall',
      );
    });

    test('Should return null when paywall URL template has invalid type', () {
      final linagoraEcosystem = LinagoraEcosystem.deserialize({
        'paywallUrlTemplate': {'url': 'invalid'},
      });

      expect(() => linagoraEcosystem.paywallUrlTemplate, returnsNormally);
      expect(linagoraEcosystem.paywallUrlTemplate, isNull);
    });
  });
}
