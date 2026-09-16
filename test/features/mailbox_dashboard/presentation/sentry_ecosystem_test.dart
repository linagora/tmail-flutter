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
    this.throwOnSaveConfiguration = false,
    this.throwOnSaveUser = false,
    this.onSaveUser,
  });

  SentryConfigurationCache configuration;
  SentryUserCache user;
  final bool throwOnSaveConfiguration;
  final bool throwOnSaveUser;
  final Future<void> Function()? onSaveUser;
  final writes = <String>[];
  final reportingUpdates = <bool>[];
  int clearCalls = 0;

  @override
  Future<SentryConfigurationCache> getSentryConfiguration() async =>
      configuration;

  @override
  Future<SentryUserCache> getSentryUser() async => user;

  @override
  Future<void> saveSentryConfiguration(
    SentryConfigurationCache sentryConfigurationCache,
  ) async {
    if (throwOnSaveConfiguration) throw StateError('config write failed');
    configuration = sentryConfigurationCache;
    writes.add('config:${configuration.isReportingAllowed}');
  }

  @override
  Future<void> saveSentryUser(SentryUserCache sentryUserCache) async {
    if (throwOnSaveUser) throw StateError('user write failed');
    user = sentryUserCache;
    writes.add('user:${user.id}');
    await onSaveUser?.call();
  }

  @override
  Future<SentryConfigurationCache?> updateSentryReportingAllowed(
    bool isReportingAllowed,
  ) async {
    reportingUpdates.add(isReportingAllowed);
    configuration = configuration.copyWith(
      isReportingAllowed: isReportingAllowed,
    );
    return configuration;
  }

  @override
  Future<void> clearSentryConfiguration() async {
    clearCalls++;
  }
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
  );

  setUp(() {
    sentryManager
      ..clearUser()
      ..setSentryReportingConsent(null)
      ..setSentryReportingDefault(true);
  });

  test('persists the latest consent when it changes while Sentry initializes', () async {
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
    await ecosystem.updateReportingConsent(false);

    expect(cacheManager.configuration.isReportingAllowed, isFalse);
    expect(cacheManager.user.id, 'account-a');

    finishInitialize.complete();
    await setUp;

    expect(initializedConfig?.isReportingAllowed, isTrue);
    expect(sentryManager.isSentryReportingAllowed, isFalse);
    expect(cacheManager.user.id, 'account-b');
    expect(cacheManager.configuration.isReportingAllowed, isFalse);
    expect(cacheManager.writes, [
      'config:false',
      'user:account-b',
    ]);
  });

  test('persists opt-out and opt-in changes after setUp in order', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: true),
      user: _user('account-a'),
    );
    final ecosystem = SentryEcosystem(
      cacheManager,
      null,
      initializeSentry: (_) async {},
    );

    await ecosystem.setUp(ecosystemConfig);
    final optOut = ecosystem.updateReportingConsent(false);
    final optIn = ecosystem.updateReportingConsent(true);
    final finalOptOut = ecosystem.updateReportingConsent(false);
    await Future.wait([optOut, optIn, finalOptOut]);

    expect(cacheManager.reportingUpdates, [false, true, false]);
    expect(cacheManager.configuration.isReportingAllowed, isFalse);
    expect(sentryManager.isSentryReportingAllowed, isFalse);
  });

  test('restores the ecosystem default when explicit consent is cleared', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: false),
      user: _user('account-a'),
    );
    SentryConfig? initializedConfig;
    final ecosystem = SentryEcosystem(
      cacheManager,
      null,
      initializeSentry: (config) async {
        initializedConfig = config;
        sentryManager.setSentryReportingDefault(config.isReportingAllowed);
      },
    );
    sentryManager.setSentryReportingConsent(false);

    await ecosystem.setUp(ecosystemConfig);

    expect(initializedConfig?.isReportingAllowed, isTrue);
    expect(sentryManager.isSentryReportingAllowed, isFalse);
    expect(cacheManager.configuration.isReportingAllowed, isFalse);

    await ecosystem.updateReportingConsent(null);

    expect(sentryManager.isSentryReportingAllowed, isTrue);
    expect(cacheManager.configuration.isReportingAllowed, isTrue);
  });

  test('does not publish allowed setup data after consent is revoked', () async {
    final userSaveStarted = Completer<void>();
    final finishUserSave = Completer<void>();
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: false),
      user: _user('account-a'),
      onSaveUser: () async {
        userSaveStarted.complete();
        await finishUserSave.future;
      },
    );
    final ecosystem = SentryEcosystem(
      cacheManager,
      null,
      initializeSentry: (_) async {},
    )..initUser(SentryUser(id: 'account-b'));

    final setUp = ecosystem.setUp(ecosystemConfig);
    await userSaveStarted.future;
    final optOut = ecosystem.updateReportingConsent(false);
    finishUserSave.complete();
    await Future.wait([setUp, optOut]);

    expect(cacheManager.writes, [
      'config:false',
      'user:account-b',
    ]);
    expect(cacheManager.configuration.isReportingAllowed, isFalse);
  });

  test('clears inconsistent cache when the config cannot be saved', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: true),
      user: _user('account-a'),
      throwOnSaveConfiguration: true,
    );
    final ecosystem = SentryEcosystem(
      cacheManager,
      null,
      initializeSentry: (_) async {},
    );

    await ecosystem.setUp(ecosystemConfig);

    expect(cacheManager.clearCalls, 1);
    expect(cacheManager.writes, isEmpty);
  });

  test('clears inconsistent cache when the user cannot be saved', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: true),
      user: _user('account-a'),
      throwOnSaveUser: true,
    );
    final ecosystem = SentryEcosystem(
      cacheManager,
      null,
      initializeSentry: (_) async {},
    )..initUser(SentryUser(id: 'account-b'));

    await ecosystem.setUp(ecosystemConfig);

    expect(cacheManager.clearCalls, 1);
    expect(cacheManager.writes, ['config:false']);
  });

}
