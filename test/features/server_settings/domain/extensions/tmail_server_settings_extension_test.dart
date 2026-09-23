import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:server_settings/server_settings/capability_server_settings.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/server_settings/domain/extensions/tmail_server_settings_extension.dart';

import '../../../../fixtures/account_fixtures.dart';

Session _session({required bool isLanguageReadOnly}) => Session(
      const {},
      {
        AccountFixtures.aliceAccountId: Account(
          AccountName('alice@domain.tld'),
          true,
          false,
          <CapabilityIdentifier, CapabilityProperties>{
            capabilityServerSettings: SettingsCapability(
              readOnlyProperties: isLanguageReadOnly ? ['language'] : [],
            ),
          },
        ),
      },
      {},
      UserName('alice@domain.tld'),
      Uri.parse('/jmap'),
      Uri.parse('/download'),
      Uri.parse('/upload'),
      Uri.parse('/eventSource'),
      State('state'),
    );

void main() {
  group('TmailServerSettingsExtension.normalized', () {
    test('returns the settings untouched when language is writable', () {
      final settings = TMailServerSettings(
        settings: TMailServerSettingOptions(language: 'fr'),
      );

      final normalized = settings.normalized(
        _session(isLanguageReadOnly: false),
        AccountFixtures.aliceAccountId,
      );

      expect(normalized.settings?.language, 'fr');
    });

    test('drops language when the server marks it read-only', () {
      final settings = TMailServerSettings(
        settings: TMailServerSettingOptions(language: 'fr'),
      );

      final normalized = settings.normalized(
        _session(isLanguageReadOnly: true),
        AccountFixtures.aliceAccountId,
      );

      expect(normalized.settings?.language, isNull);
    });

    test('keeps every other known setting when dropping language', () {
      final settings = TMailServerSettings(
        settings: TMailServerSettingOptions(
          language: 'fr',
          alwaysReadReceipts: true,
          displaySenderPriority: false,
          aiLabelCategorizationEnabled: true,
          sentryUserOptIn: true,
        ),
      );

      final normalized = settings.normalized(
        _session(isLanguageReadOnly: true),
        AccountFixtures.aliceAccountId,
      );

      expect(normalized.settings?.alwaysReadReceipts, isTrue);
      expect(normalized.settings?.displaySenderPriority, isFalse);
      expect(normalized.settings?.aiLabelCategorizationEnabled, isTrue);
      expect(normalized.settings?.sentryUserOptIn, isTrue,
          reason: 'a read-only language must not erase the Sentry opt-in');
    });

    test('preserves the settings id so the update targets the same singleton', () {
      final settings = TMailServerSettings(
        settings: TMailServerSettingOptions(language: 'fr'),
      );

      final normalized = settings.normalized(
        _session(isLanguageReadOnly: true),
        AccountFixtures.aliceAccountId,
      );

      expect(normalized.id, settings.id);
    });

    test('tolerates a settings payload that is absent', () {
      final normalized = TMailServerSettings().normalized(
        _session(isLanguageReadOnly: true),
        AccountFixtures.aliceAccountId,
      );

      expect(normalized.settings?.toJson(), isEmpty);
    });
  });
}
