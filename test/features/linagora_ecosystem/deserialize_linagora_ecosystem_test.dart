import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/api_key_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/api_url_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/default_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/empty_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/mobile_apps_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';

void main() {
  group('Deserialize LinagoraEcosystem test', () {
    test('Should parse correctly when all properties are present', () {
      const linagoraEcosystemString = '''
        {
          "linShareApiUrl": "https://example.com/api",
          "linToApiUrl": "https://example.com/api",
          "linToApiKey": "apiKey",
          "twakeApiUrl": "https://example.com/api",
          "Twake Drive": {
            "appName": "Twake Drive",
            "logoURL": "https://xyz",
            "webLink": "https://abc"
          },
          "mobileApps": {
            "Twake Chat": {
              "appName": "Twake Chat",
              "logoURL": "https://xyz",
              "androidPackageId": "com.example.android",
              "iosUrlScheme": "app.scheme",
              "iosAppStoreLink": "itms-apps://itunes.apple.com/app"
            },
            "Twake Sync": {
              "appName": "Twake Sync",
              "logoURL": "https://xyz",
              "androidPackageId": "com.example.android"
            },
            "LinShare": {
              "appName": "LinShare",
              "logoURL": "https://xyz",
              "androidPackageId": "com.example.android",
              "iosUrlScheme": "app.scheme",
              "iosAppStoreLink": "itms-apps://itunes.apple.com/app"
            }
          }
        }
      ''';

      final expectedLinagoraEcosystem = LinagoraEcosystem({
        LinagoraEcosystemIdentifier.linShareApiUrl: ApiUrlLinagoraEcosystem('https://example.com/api'),
        LinagoraEcosystemIdentifier.linToApiUrl: ApiUrlLinagoraEcosystem('https://example.com/api'),
        LinagoraEcosystemIdentifier.linToApiKey: ApiKeyLinagoraEcosystem('apiKey'),
        LinagoraEcosystemIdentifier.twakeApiUrl: ApiUrlLinagoraEcosystem('https://example.com/api'),
        LinagoraEcosystemIdentifier.twakeDrive: AppLinagoraEcosystem(
          appName: 'Twake Drive',
          logoURL: 'https://xyz',
          webLink: Uri.parse('https://abc'),
        ),
        LinagoraEcosystemIdentifier.mobileApps: MobileAppsLinagoraEcosystem({
          LinagoraEcosystemIdentifier.twakeChat: AppLinagoraEcosystem(
            appName: 'Twake Chat',
            logoURL: 'https://xyz',
            androidPackageId: 'com.example.android',
            iosUrlScheme: 'app.scheme',
            iosAppStoreLink: 'itms-apps://itunes.apple.com/app',
          ),
          LinagoraEcosystemIdentifier.twakeSync: AppLinagoraEcosystem(
            appName: 'Twake Sync',
            logoURL: 'https://xyz',
            androidPackageId: 'com.example.android',
          ),
          LinagoraEcosystemIdentifier.linShare: AppLinagoraEcosystem(
            appName: 'LinShare',
            logoURL: 'https://xyz',
            androidPackageId: 'com.example.android',
            iosUrlScheme: 'app.scheme',
            iosAppStoreLink: 'itms-apps://itunes.apple.com/app',
          ),
        }),
      });

      final parsedLinagoraEcosystem = LinagoraEcosystem.deserialize(json.decode(linagoraEcosystemString));

      expect(parsedLinagoraEcosystem, equals(expectedLinagoraEcosystem));
    });

    test('Should parse correctly when some properties are null', () {
      const linagoraEcosystemString = '''
        {
          "linShareApiUrl": "https://example.com/api",
          "linToApiUrl": null,
          "linToApiKey": "apiKey",
          "twakeApiUrl": "https://example.com/api",
          "Twake Drive": null,
          "mobileApps": {
            "Twake Chat": {
              "appName": "Twake Chat",
              "logoURL": "https://xyz",
              "androidPackageId": "com.example.android",
              "iosUrlScheme": "app.scheme",
              "iosAppStoreLink": "itms-apps://itunes.apple.com/app"
            },
            "Twake Sync": null,
            "LinShare": {
              "appName": "LinShare",
              "logoURL": "https://xyz",
              "androidPackageId": "com.example.android",
              "iosUrlScheme": "app.scheme",
              "iosAppStoreLink": "itms-apps://itunes.apple.com/app"
            }
          }
        }
      ''';

      final expectedLinagoraEcosystem = LinagoraEcosystem({
        LinagoraEcosystemIdentifier.linShareApiUrl: ApiUrlLinagoraEcosystem('https://example.com/api'),
        LinagoraEcosystemIdentifier.linToApiUrl: EmptyLinagoraEcosystem(),
        LinagoraEcosystemIdentifier.linToApiKey: ApiKeyLinagoraEcosystem('apiKey'),
        LinagoraEcosystemIdentifier.twakeApiUrl: ApiUrlLinagoraEcosystem('https://example.com/api'),
        LinagoraEcosystemIdentifier.twakeDrive: EmptyLinagoraEcosystem(),
        LinagoraEcosystemIdentifier.mobileApps: MobileAppsLinagoraEcosystem({
          LinagoraEcosystemIdentifier.twakeChat: AppLinagoraEcosystem(
            appName: 'Twake Chat',
            logoURL: 'https://xyz',
            androidPackageId: 'com.example.android',
            iosUrlScheme: 'app.scheme',
            iosAppStoreLink: 'itms-apps://itunes.apple.com/app',
          ),
          LinagoraEcosystemIdentifier.twakeSync: EmptyLinagoraEcosystem(),
          LinagoraEcosystemIdentifier.linShare: AppLinagoraEcosystem(
            appName: 'LinShare',
            logoURL: 'https://xyz',
            androidPackageId: 'com.example.android',
            iosUrlScheme: 'app.scheme',
            iosAppStoreLink: 'itms-apps://itunes.apple.com/app',
          ),
        }),
      });

      final parsedLinagoraEcosystem = LinagoraEcosystem.deserialize(json.decode(linagoraEcosystemString));

      expect(parsedLinagoraEcosystem, equals(expectedLinagoraEcosystem));
    });

    test('Should parse correctly when some properties are not default', () {
      const linagoraEcosystemString = '''
        {
          "abc": "https://example.com/api",
          "custom": "apiKey",
          "twakeApiUrl": "https://example.com/api",
          "mobileApps": {
            "Twake Chat": {
              "appName": "Twake Chat",
              "logoURL": "https://xyz",
              "androidPackageId": "com.example.android",
              "iosUrlScheme": "app.scheme",
              "iosAppStoreLink": "itms-apps://itunes.apple.com/app"
            },
            "xyz": {
              "appName": "LinShare",
              "logoURL": "https://xyz"
            },
            "dab": "test"
          }
        }
      ''';

      final expectedLinagoraEcosystem = LinagoraEcosystem({
        LinagoraEcosystemIdentifier('abc'): DefaultLinagoraEcosystem('https://example.com/api'),
        LinagoraEcosystemIdentifier('custom'): DefaultLinagoraEcosystem('apiKey'),
        LinagoraEcosystemIdentifier.twakeApiUrl: ApiUrlLinagoraEcosystem('https://example.com/api'),
        LinagoraEcosystemIdentifier.mobileApps: MobileAppsLinagoraEcosystem({
          LinagoraEcosystemIdentifier.twakeChat: AppLinagoraEcosystem(
            appName: 'Twake Chat',
            logoURL: 'https://xyz',
            androidPackageId: 'com.example.android',
            iosUrlScheme: 'app.scheme',
            iosAppStoreLink: 'itms-apps://itunes.apple.com/app',
          ),
          LinagoraEcosystemIdentifier('xyz'): AppLinagoraEcosystem(
            appName: 'LinShare',
            logoURL: 'https://xyz'
          ),
          LinagoraEcosystemIdentifier('dab'): DefaultLinagoraEcosystem('test'),
        }),
      });

      final parsedLinagoraEcosystem = LinagoraEcosystem.deserialize(json.decode(linagoraEcosystemString));

      expect(parsedLinagoraEcosystem, equals(expectedLinagoraEcosystem));
    });
  });

  group('Deserialize LinagoraEcosystem with paywallURL & sentryConfig', () {
    test('Should parse paywallURL correctly when value is string', () {
      const jsonString = '''
      {
        "paywallUrlTemplate": "https://paywall.example.com/{userId}"
      }
    ''';

      final expected = LinagoraEcosystem({
        LinagoraEcosystemIdentifier.paywallURL:
            ApiUrlLinagoraEcosystem('https://paywall.example.com/{userId}'),
      });

      final parsed = LinagoraEcosystem.deserialize(json.decode(jsonString));

      expect(parsed, equals(expected));
    });

    test('Should parse paywallURL as EmptyLinagoraEcosystem when value is null',
        () {
      const jsonString = '''
      {
        "paywallUrlTemplate": null
      }
    ''';

      final parsed = LinagoraEcosystem.deserialize(json.decode(jsonString));

      expect(
        parsed.properties![LinagoraEcosystemIdentifier.paywallURL],
        isA<EmptyLinagoraEcosystem>(),
      );
    });

    test('Should parse sentryConfig correctly when all fields are present', () {
      const jsonString = '''
      {
        "sentry": {
          "enabled": true,
          "dsn": "https://dsn@sentry.io/123",
          "environment": "production"
        }
      }
    ''';

      final expected = LinagoraEcosystem({
        LinagoraEcosystemIdentifier.sentryConfig: SentryConfigLinagoraEcosystem(
          enabled: true,
          dsn: 'https://dsn@sentry.io/123',
          environment: 'production',
        ),
      });

      final parsed = LinagoraEcosystem.deserialize(json.decode(jsonString));

      expect(parsed, equals(expected));
    });

    test('Should parse sentryConfig with partial fields', () {
      const jsonString = '''
      {
        "sentry": {
          "enabled": false
        }
      }
    ''';

      final expected = LinagoraEcosystem({
        LinagoraEcosystemIdentifier.sentryConfig: SentryConfigLinagoraEcosystem(
          enabled: false,
          dsn: null,
          environment: null,
        ),
      });

      final parsed = LinagoraEcosystem.deserialize(json.decode(jsonString));

      expect(parsed, equals(expected));
    });

    test(
        'Should parse sentryConfig as EmptyLinagoraEcosystem when value is null',
        () {
      const jsonString = '''
      {
        "sentry": null
      }
    ''';

      final parsed = LinagoraEcosystem.deserialize(json.decode(jsonString));

      expect(
        parsed.properties![LinagoraEcosystemIdentifier.sentryConfig],
        isA<EmptyLinagoraEcosystem>(),
      );
    });

    test(
        'Should parse sentryConfig as EmptyLinagoraEcosystem when value is not Map',
        () {
      const jsonString = '''
      {
        "sentry": "invalid"
      }
    ''';

      final parsed = LinagoraEcosystem.deserialize(json.decode(jsonString));

      expect(
        parsed.properties![LinagoraEcosystemIdentifier.sentryConfig],
        isA<EmptyLinagoraEcosystem>(),
      );
    });

    test(
        'Should parse paywallURL + sentryConfig together with other properties',
        () {
      const jsonString = '''
      {
        "linShareApiUrl": "https://example.com/api",
        "paywallUrlTemplate": "https://paywall.example.com",
        "sentry": {
          "enabled": true,
          "dsn": "dsn_value"
        }
      }
    ''';

      final expected = LinagoraEcosystem({
        LinagoraEcosystemIdentifier.linShareApiUrl:
            ApiUrlLinagoraEcosystem('https://example.com/api'),
        LinagoraEcosystemIdentifier.paywallURL:
            ApiUrlLinagoraEcosystem('https://paywall.example.com'),
        LinagoraEcosystemIdentifier.sentryConfig: SentryConfigLinagoraEcosystem(
          enabled: true,
          dsn: 'dsn_value',
          environment: null,
        ),
      });

      final parsed = LinagoraEcosystem.deserialize(json.decode(jsonString));

      expect(parsed, equals(expected));
    });

    test('Should fallback sentryConfig to Empty when exception occurs', () {
      const jsonString = '''
      {
        "sentry": {
          "enabled": "not_a_boolean"
        }
      }
    ''';

      final parsed = LinagoraEcosystem.deserialize(json.decode(jsonString));

      expect(
        parsed.properties![LinagoraEcosystemIdentifier.sentryConfig],
        isA<EmptyLinagoraEcosystem>(),
      );
    });

    test('Should treat unknown object as DefaultLinagoraEcosystem', () {
      const jsonString = '''
      {
        "unknownConfig": {
          "abc": "123"
        }
      }
    ''';

      final parsed = LinagoraEcosystem.deserialize(json.decode(jsonString));

      expect(
        parsed.properties!.keys.first.value,
        equals('unknownConfig'),
      );
      expect(
        parsed.properties!.values.first,
        isA<AppLinagoraEcosystem>(),
      );
    });
  });
}
