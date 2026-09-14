import 'dart:async';

import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_user_cache.dart';
import 'package:tmail_ui_user/features/caching/manager/sentry_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/sentry_ecosystem.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

import 'sentry_ecosystem_test.mocks.dart';

@GenerateNiceMocks([MockSpec<IOSSharingManager>()])

class _FakeCacheManager implements SentryConfigurationCacheManager {
  _FakeCacheManager({
    required this.configuration,
    required this.user,
    this.throwOnSaveConfiguration = false,
    this.throwOnSaveUser = false,
    this.returnNullOnUpdate = false,
  });

  SentryConfigurationCache configuration;
  SentryUserCache user;
  final bool throwOnSaveConfiguration;
  final bool throwOnSaveUser;
  final bool returnNullOnUpdate;
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
  }

  @override
  Future<SentryConfigurationCache?> updateSentryReportingAllowed(
    bool isReportingAllowed,
  ) async {
    reportingUpdates.add(isReportingAllowed);
    if (returnNullOnUpdate) return null;
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
    userOptInByDefault: false,
  );

  setUp(() {
    debugDefaultTargetPlatformOverride = null;
    sentryManager
      ..clearUser()
      ..setSentryReportingConsent(null)
      ..setSentryReportingDefault(true);
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('persists the latest consent when it changes while Sentry initializes', () async {
    final optedInByDefaultConfig = SentryConfigLinagoraEcosystem(
      enabled: true,
      dsn: 'https://test@sentry.io/123',
      environment: 'test',
      userOptInByDefault: true,
    );
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

    final setUp = ecosystem.setUp(optedInByDefaultConfig);
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

  test('persists an opt-in that arrives while opted-out Sentry initializes', () async {
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

  test('updates iOS Keychain when reporting consent changes', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final optedInByDefaultConfig = SentryConfigLinagoraEcosystem(
      enabled: true,
      dsn: 'https://test@sentry.io/123',
      environment: 'test',
      userOptInByDefault: true,
    );
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: true),
      user: _user('account-a'),
    );
    final iosSharingManager = MockIOSSharingManager();
    final ecosystem = SentryEcosystem(
      cacheManager,
      iosSharingManager,
      initializeSentry: (_) async {},
    );

    await ecosystem.setUp(optedInByDefaultConfig);
    await ecosystem.updateReportingConsent(false);

    final savedConfigs = verify(
      iosSharingManager.saveSentryConfigToKeychain(captureAny),
    ).captured.cast<SentryConfig>();
    expect(savedConfigs.map((config) => config.isReportingAllowed), [true, false]);
  });

  test('persists fail-closed iOS config when cache update fails', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: true),
      user: _user('account-a'),
      returnNullOnUpdate: true,
    );
    final iosSharingManager = MockIOSSharingManager();
    final ecosystem = SentryEcosystem(
      cacheManager,
      iosSharingManager,
      initializeSentry: (_) async {},
    );

    await ecosystem.setUp(ecosystemConfig);
    await ecosystem.updateReportingConsent(false);

    expect(cacheManager.reportingUpdates, [false]);
    final savedConfigs = verify(
      iosSharingManager.saveSentryConfigToKeychain(captureAny),
    ).captured.cast<SentryConfig>();
    expect(savedConfigs.last.isReportingAllowed, isFalse);
    expect(sentryManager.isSentryReportingAllowed, isFalse);
  });
}
