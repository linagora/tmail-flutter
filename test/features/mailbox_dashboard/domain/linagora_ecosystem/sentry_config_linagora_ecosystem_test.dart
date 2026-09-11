import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';

void main() {
  group('SentryConfigLinagoraEcosystem.isUserOptedInByDefault', () {
    test('uses userOptInByDefault when the instance serves it', () {
      final config = SentryConfigLinagoraEcosystem.fromJson({
        'enabled': 'true',
        'userOptInByDefault': 'false',
      });

      expect(config.isUserOptedInByDefault, isFalse);
    });

    test('opts users in when the instance serves userOptInByDefault true', () {
      final config = SentryConfigLinagoraEcosystem.fromJson({
        'enabled': 'true',
        'userOptInByDefault': 'true',
      });

      expect(config.isUserOptedInByDefault, isTrue);
    });

    test('falls back to enabled so deployments without the key are unaffected', () {
      final config = SentryConfigLinagoraEcosystem.fromJson({'enabled': 'true'});

      expect(config.isUserOptedInByDefault, isTrue);
    });

    test('defaults to opted out when neither key is served', () {
      final config = SentryConfigLinagoraEcosystem.fromJson({});

      expect(config.isUserOptedInByDefault, isFalse);
    });

    test('accepts booleans as well as strings', () {
      final config = SentryConfigLinagoraEcosystem.fromJson({
        'enabled': true,
        'userOptInByDefault': false,
      });

      expect(config.isUserOptedInByDefault, isFalse);
    });
  });
}
