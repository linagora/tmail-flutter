import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/sentry_ecosystem_handler.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('forwards Sentry ecosystem config without choosing its setup source',
      () async {
    SentryConfigLinagoraEcosystem? forwardedConfig;
    final handler = SentryEcosystemHandler(
      setUpSentry: (config) async {
        forwardedConfig = config;
      },
      clearSentry: () async {},
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

  test('owns asynchronous setup and clear failures', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final uncaughtErrors = <Object>[];
    final handler = SentryEcosystemHandler(
      setUpSentry: (_) async {
        throw StateError('setup failed');
      },
      clearSentry: () async {
        throw StateError('clear failed');
      },
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
        handler.onEcosystemCleared();
        await Future<void>.delayed(Duration.zero);
      },
      (error, _) => uncaughtErrors.add(error),
    );
    await execution;

    expect(uncaughtErrors, isEmpty);
  });
}
