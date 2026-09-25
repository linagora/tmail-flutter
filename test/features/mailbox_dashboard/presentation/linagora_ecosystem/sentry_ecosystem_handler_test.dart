import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/sentry_ecosystem_handler.dart';

void main() {
  test('forwards Sentry ecosystem config to non-web setup', () async {
    SentryConfigLinagoraEcosystem? forwardedConfig;
    final handler = SentryEcosystemHandler(
      setUpSentry: (config) async {
        forwardedConfig = config;
      },
      clearSentry: () async {},
      resetSentryReportingConsent: () {},
    );

    handler.onEcosystemLoaded(LinagoraEcosystem.deserialize({
      'sentry': {
        'enabled': true,
        'dsn': 'https://test@sentry.io/123',
        'environment': 'test',
        'userOptInByDefault': false,
      },
    }));
    await Future<void>.delayed(Duration.zero);

    expect(forwardedConfig?.userOptInByDefault, isFalse);
  });

  test('clears non-web Sentry when the loaded ecosystem has no config',
      () async {
    var clearCalls = 0;
    final handler = SentryEcosystemHandler(
      setUpSentry: (_) async {},
      clearSentry: () async {
        clearCalls++;
      },
      resetSentryReportingConsent: () {},
    );

    handler.onEcosystemLoaded(LinagoraEcosystem.deserialize({
      'paywallUrlTemplate': 'https://domain.tld/premium',
    }));
    await Future<void>.delayed(Duration.zero);

    expect(clearCalls, 1);
  });

  test('resets non-web Sentry consent when the account changes', () {
    var resetCalls = 0;
    final handler = SentryEcosystemHandler(
      setUpSentry: (_) async {},
      clearSentry: () async {},
      resetSentryReportingConsent: () {
        resetCalls++;
      },
    );

    handler.onAccountChanged();

    expect(resetCalls, 1);
  });

  test('owns asynchronous setup and clear failures', () async {
    final uncaughtErrors = <Object>[];
    final handler = SentryEcosystemHandler(
      setUpSentry: (_) async {
        throw StateError('setup failed');
      },
      clearSentry: () async {
        throw StateError('clear failed');
      },
      resetSentryReportingConsent: () {},
    );

    final execution = runZonedGuarded<Future<void>>(
      () async {
        handler.onEcosystemLoaded(LinagoraEcosystem.deserialize({
          'sentry': {
            'enabled': true,
            'dsn': 'https://test@sentry.io/123',
            'environment': 'test',
          },
        }));
        handler.onEcosystemLoaded(LinagoraEcosystem.deserialize({}));
        handler.onEcosystemCleared();
        await Future<void>.delayed(Duration.zero);
      },
      (error, _) => uncaughtErrors.add(error),
    );
    await execution;

    expect(uncaughtErrors, isEmpty);
  });
}
