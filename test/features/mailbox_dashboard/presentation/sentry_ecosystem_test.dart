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

class _RecordingIOSSharingManager implements IOSSharingManager {
  final savedConfigs = <SentryConfig>[];
  int deleteCalls = 0;
  Future<void> Function()? onSave;

  @override
  Future<void> saveSentryConfigToKeychain(SentryConfig sentryConfig) async {
    savedConfigs.add(sentryConfig);
    await onSave?.call();
  }

  @override
  Future<void> deleteSentryConfigFromKeychain() async {
    deleteCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCacheManager implements SentryConfigurationCacheManager {
  _FakeCacheManager({
    required this.configuration,
    required this.user,
    this.throwOnSaveConfiguration = false,
    this.throwOnSaveUser = false,
    this.throwOnClear = false,
    this.reportingUpdateFailures = 0,
    this.onSaveUser,
    this.onUpdate,
    this.returnNullOnUpdate = false,
    this.throwOnUpdate = false,
  });

  SentryConfigurationCache configuration;
  SentryUserCache user;
  final bool throwOnSaveConfiguration;
  final bool throwOnSaveUser;
  final bool throwOnClear;
  int reportingUpdateFailures;
  final Future<void> Function()? onSaveUser;
  final Future<void> Function()? onUpdate;
  final bool returnNullOnUpdate;
  final bool throwOnUpdate;
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
    if (reportingUpdateFailures > 0) {
      reportingUpdateFailures--;
      throw StateError('reporting update failed');
    }
    if (throwOnUpdate) throw StateError('update failed');
    if (returnNullOnUpdate) return null;
    configuration = configuration.copyWith(
      isReportingAllowed: isReportingAllowed,
    );
    await onUpdate?.call();
    return configuration;
  }

  @override
  Future<void> clearSentryConfiguration() async {
    clearCalls++;
    if (throwOnClear) throw StateError('clear failed');
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

@GenerateNiceMocks([MockSpec<IOSSharingManager>()])
void main() {
  final sentryManager = SentryManager.instance;
  final ecosystemConfig = SentryConfigLinagoraEcosystem(
    enabled: true,
    dsn: 'https://test@sentry.io/123',
    environment: 'test',
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

  test('a failed consent write does not poison later persistence', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: true),
      user: _user('account-a'),
      reportingUpdateFailures: 1,
    );
    final ecosystem = SentryEcosystem(
      cacheManager,
      null,
      initializeSentry: (_) async {},
    );

    await ecosystem.setUp(ecosystemConfig);
    await expectLater(
      ecosystem.updateReportingConsent(false),
      throwsA(isA<StateError>()),
    );
    await ecosystem.updateReportingConsent(true);

    expect(cacheManager.reportingUpdates, [false, true]);
    expect(cacheManager.configuration.isReportingAllowed, isTrue);
    expect(sentryManager.isSentryReportingAllowed, isTrue);
  });

  test('a failed setup write does not poison later consent persistence', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: true),
      user: _user('account-a'),
      throwOnSaveConfiguration: true,
      throwOnClear: true,
    );
    final ecosystem = SentryEcosystem(
      cacheManager,
      null,
      initializeSentry: (_) async {},
    );

    await expectLater(
      ecosystem.setUp(ecosystemConfig),
      throwsStateError,
    );
    await ecosystem.updateReportingConsent(false);

    expect(cacheManager.reportingUpdates, [false]);
    expect(cacheManager.configuration.isReportingAllowed, isFalse);
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

  test('updates iOS Keychain when reporting consent changes', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
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

    await ecosystem.setUp(ecosystemConfig);
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

  test('does not enable iOS Keychain when opt-in cache update fails', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: false),
      user: _user('account-a'),
      returnNullOnUpdate: true,
    );
    final iosSharingManager = MockIOSSharingManager();
    final ecosystem = SentryEcosystem(
      cacheManager,
      iosSharingManager,
      initializeSentry: (_) async {},
    );
    sentryManager.setSentryReportingConsent(false);

    await ecosystem.setUp(ecosystemConfig);
    await ecosystem.updateReportingConsent(true);

    final savedConfigs = verify(
      iosSharingManager.saveSentryConfigToKeychain(captureAny),
    ).captured.cast<SentryConfig>();
    expect(savedConfigs.map((config) => config.isReportingAllowed), [false, false]);
  });

  test('does not enable iOS Keychain when cache update throws', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: false),
      user: _user('account-a'),
      throwOnUpdate: true,
    );
    final iosSharingManager = MockIOSSharingManager();
    final ecosystem = SentryEcosystem(
      cacheManager,
      iosSharingManager,
      initializeSentry: (_) async {},
    );
    sentryManager.setSentryReportingConsent(false);

    await ecosystem.setUp(ecosystemConfig);

    await expectLater(
      ecosystem.updateReportingConsent(true),
      throwsA(isA<StateError>()),
    );
    final savedConfigs = verify(
      iosSharingManager.saveSentryConfigToKeychain(captureAny),
    ).captured.cast<SentryConfig>();
    expect(savedConfigs.map((config) => config.isReportingAllowed), [false, false]);
  });

  test('does not publish allowed iOS config after consent is revoked during setup', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
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
    final iosSharingManager = MockIOSSharingManager();
    final ecosystem = SentryEcosystem(
      cacheManager,
      iosSharingManager,
      initializeSentry: (_) async {},
    )..initUser(SentryUser(id: 'account-b'));

    final setUp = ecosystem.setUp(ecosystemConfig);
    await userSaveStarted.future;
    final optOut = ecosystem.updateReportingConsent(false);
    finishUserSave.complete();
    await Future.wait([setUp, optOut]);

    final savedConfigs = verify(
      iosSharingManager.saveSentryConfigToKeychain(captureAny),
    ).captured.cast<SentryConfig>();
    expect(
      savedConfigs.map((config) => config.isReportingAllowed),
      everyElement(isFalse),
    );
  });

  test('does not publish allowed iOS config when opt-in is superseded by opt-out', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final updateStarted = Completer<void>();
    final finishUpdate = Completer<void>();
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: false),
      user: _user('account-a'),
      onUpdate: () async {
        if (!updateStarted.isCompleted) {
          updateStarted.complete();
        }
        await finishUpdate.future;
      },
    );
    final iosSharingManager = MockIOSSharingManager();
    final ecosystem = SentryEcosystem(
      cacheManager,
      iosSharingManager,
      initializeSentry: (_) async {},
    );
    sentryManager.setSentryReportingConsent(false);

    await ecosystem.setUp(ecosystemConfig);
    final optIn = ecosystem.updateReportingConsent(true);
    await updateStarted.future;
    final optOut = ecosystem.updateReportingConsent(false);
    finishUpdate.complete();
    await Future.wait([optIn, optOut]);

    final savedConfigs = verify(
      iosSharingManager.saveSentryConfigToKeychain(captureAny),
    ).captured.cast<SentryConfig>();
    expect(
      savedConfigs.map((config) => config.isReportingAllowed),
      everyElement(isFalse),
    );
  });

  test('does not enable iOS Keychain when setup cache commit fails', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: false),
      user: _user('account-a'),
      throwOnSaveConfiguration: true,
    );
    final iosSharingManager = MockIOSSharingManager();
    final ecosystem = SentryEcosystem(
      cacheManager,
      iosSharingManager,
      initializeSentry: (_) async {},
    );

    await ecosystem.setUp(ecosystemConfig);

    final savedConfig = verify(
      iosSharingManager.saveSentryConfigToKeychain(captureAny),
    ).captured.single as SentryConfig;
    expect(savedConfig.isReportingAllowed, isFalse);
  });

  test('publishes denied iOS config when setup cache cleanup fails', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: true),
      user: _user('account-a'),
      throwOnSaveConfiguration: true,
      throwOnClear: true,
    );
    final iosSharingManager = MockIOSSharingManager();
    final ecosystem = SentryEcosystem(
      cacheManager,
      iosSharingManager,
      initializeSentry: (_) async {},
    );

    await expectLater(
      ecosystem.setUp(ecosystemConfig),
      throwsStateError,
    );

    final savedConfig = verify(
      iosSharingManager.saveSentryConfigToKeychain(captureAny),
    ).captured.single as SentryConfig;
    expect(savedConfig.isReportingAllowed, isFalse);
  });

  test('does not publish a setup superseded by ecosystem clearing', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final initializeStarted = Completer<void>();
    final finishInitialize = Completer<void>();
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: true),
      user: _user('account-a'),
    );
    final iosSharingManager = _RecordingIOSSharingManager();
    final ecosystem = SentryEcosystem(
      cacheManager,
      iosSharingManager,
      initializeSentry: (_) async {
        initializeStarted.complete();
        await finishInitialize.future;
      },
    )..initUser(SentryUser(id: 'account-a'));

    final setUp = ecosystem.setUp(ecosystemConfig);
    await initializeStarted.future;
    final clear = ecosystem.clear();
    finishInitialize.complete();
    await Future.wait([setUp, clear]);

    expect(iosSharingManager.savedConfigs, isEmpty);
    expect(iosSharingManager.deleteCalls, 1);
  });

  test('deletes a published config when clearing races with its Keychain write', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final saveStarted = Completer<void>();
    final finishSave = Completer<void>();
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: true),
      user: _user('account-a'),
    );
    final iosSharingManager = _RecordingIOSSharingManager()
      ..onSave = () async {
        saveStarted.complete();
        await finishSave.future;
      };
    final ecosystem = SentryEcosystem(
      cacheManager,
      iosSharingManager,
      initializeSentry: (_) async {},
    );

    final setUp = ecosystem.setUp(ecosystemConfig);
    await saveStarted.future;
    final clear = ecosystem.clear();
    finishSave.complete();
    await Future.wait([setUp, clear]);

    expect(iosSharingManager.savedConfigs, hasLength(1));
    expect(iosSharingManager.deleteCalls, 1);
  });

  test('deletes the shared config when the ecosystem disables Sentry', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: true),
      user: _user('account-a'),
    );
    final iosSharingManager = _RecordingIOSSharingManager();
    final ecosystem = SentryEcosystem(
      cacheManager,
      iosSharingManager,
      initializeSentry: (_) async {},
    )..initUser(SentryUser(id: 'account-a'));

    await ecosystem.setUp(SentryConfigLinagoraEcosystem(
      enabled: false,
      dsn: 'https://test@sentry.io/123',
      environment: 'test',
    ));

    expect(iosSharingManager.savedConfigs, isEmpty);
    expect(iosSharingManager.deleteCalls, 1);
  });

  test('session cleanup clears user and Keychain before Sentry setup', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(isReportingAllowed: true),
      user: _user('account-a'),
    );
    final iosSharingManager = _RecordingIOSSharingManager();
    final ecosystem = SentryEcosystem(
      cacheManager,
      iosSharingManager,
      initializeSentry: (_) async {},
    );
    sentryManager.setUser(SentryUser(id: 'account-a'));

    await ecosystem.clearForSessionEnd();

    expect(sentryManager.userForScope, isNull);
    expect(iosSharingManager.deleteCalls, 1);
  });

  test('session cleanup does not carry an opt-in over to the next account', () async {
    final ecosystem = SentryEcosystem(
      null,
      null,
      initializeSentry: (_) async {},
    );
    sentryManager
      ..setSentryReportingDefault(false)
      ..setSentryReportingConsent(true);

    await ecosystem.clearForSessionEnd();

    expect(
      sentryManager.isSentryReportingAllowed,
      isFalse,
      reason: 'the next account has not chosen yet, so the instance default '
          'must apply, as on a cold start',
    );
  });

  test('session cleanup does not carry an opt-out over to the next account', () async {
    final ecosystem = SentryEcosystem(
      null,
      null,
      initializeSentry: (_) async {},
    );
    sentryManager
      ..setSentryReportingDefault(true)
      ..setSentryReportingConsent(false);

    await ecosystem.clearForSessionEnd();

    expect(
      sentryManager.isSentryReportingAllowed,
      isTrue,
      reason: 'the next account has not chosen yet, so the instance default '
          'must apply, as on a cold start',
    );
  });

}
