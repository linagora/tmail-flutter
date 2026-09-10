import 'dart:async';

import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_user_cache.dart';
import 'package:tmail_ui_user/features/caching/manager/sentry_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/sentry_ecosystem.dart';

class _FakeCacheManager implements SentryConfigurationCacheManager {
  _FakeCacheManager({
    required this.configuration,
    required this.user,
  });

  SentryConfigurationCache configuration;
  SentryUserCache user;
  final writes = <String>[];

  @override
  Future<SentryConfigurationCache> getSentryConfiguration() async =>
      configuration;

  @override
  Future<SentryUserCache> getSentryUser() async => user;

  @override
  Future<void> saveSentryConfiguration(
    SentryConfigurationCache sentryConfigurationCache,
  ) async {
    configuration = sentryConfigurationCache;
    writes.add('config:${configuration.isReportingAllowed}');
  }

  @override
  Future<void> saveSentryUser(SentryUserCache sentryUserCache) async {
    user = sentryUserCache;
    writes.add('user:${user.id}');
  }

  @override
  Future<SentryConfigurationCache?> updateSentryReportingAllowed(
    bool isReportingAllowed,
  ) async {
    configuration = configuration.copyWith(
      isReportingAllowed: isReportingAllowed,
    );
    return configuration;
  }

  @override
  Future<void> clearSentryConfiguration() async {}
}

SentryConfigurationCache _configuration({
  required bool isReportingAllowed,
}) =>
    SentryConfigurationCache(
      dsn: 'https://test@sentry.io/123',
      environment: 'test',
      release: '1.0.0',
      tracesSampleRate: 0.1,
      profilesSampleRate: 0.1,
      enableLogs: true,
      isDebug: false,
      attachScreenshot: false,
      isAvailable: true,
      sessionSampleRate: null,
      onErrorSampleRate: null,
      enableFramesTracking: true,
      dist: null,
      isReportingAllowed: isReportingAllowed,
    );

SentryUserCache _user(String id) => SentryUserCache(
      id: id,
      name: '',
      username: '',
      email: '',
    );

void main() {
  final sentryManager = SentryManager.instance;
  final ecosystemConfig = SentryConfigLinagoraEcosystem(
    enabled: true,
    dsn: 'https://test@sentry.io/123',
    environment: 'test',
    userOptInByDefault: false,
  );

  setUp(() {
    sentryManager
      ..clearUser()
      ..setSentryReportingConsent(null)
      ..setSentryReportingDefault(true);
  });

  test('does not publish consent before the current account config is ready', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: false),
      user: _user('account-a'),
    );
    SentryConfig? initializedConfig;
    final initializeStarted = Completer<void>();
    final finishInitialize = Completer<void>();
    final ecosystem = SentryEcosystem(
      cacheManager,
      null,
      initializeSentry: (config) async {
        initializedConfig = config;
        initializeStarted.complete();
        await finishInitialize.future;
      },
    )..initUser(SentryUser(id: 'account-b'));

    final setUp = ecosystem.setUp(ecosystemConfig);
    await initializeStarted.future;
    await ecosystem.updateReportingConsent(true);

    expect(cacheManager.configuration.isReportingAllowed, isFalse);
    expect(cacheManager.user.id, 'account-a');

    finishInitialize.complete();
    await setUp;

    expect(initializedConfig?.isReportingAllowed, isFalse);
    expect(sentryManager.isSentryReportingAllowed, isTrue);
    expect(cacheManager.user.id, 'account-b');
    expect(cacheManager.configuration.isReportingAllowed, isTrue);
    expect(cacheManager.writes, [
      'config:false',
      'user:account-b',
      'config:true',
    ]);
  });

  test('uses the ecosystem default while the user has not chosen', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: true),
      user: _user('account-b'),
    );
    SentryConfig? initializedConfig;
    final ecosystem = SentryEcosystem(
      cacheManager,
      null,
      initializeSentry: (config) async => initializedConfig = config,
    )..initUser(SentryUser(id: 'account-b'));

    await ecosystem.setUp(ecosystemConfig);

    expect(sentryManager.isSentryReportingAllowed, isFalse);
    expect(initializedConfig?.isReportingAllowed, isFalse);
  });
}
