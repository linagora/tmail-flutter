import 'dart:async';

import 'package:core/utils/sentry/sentry_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_user_cache.dart';
import 'package:tmail_ui_user/features/caching/manager/sentry_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_message_controller.dart';

class _FakeCacheManager implements SentryConfigurationCacheManager {
  _FakeCacheManager({
    this.configuration,
    this.user,
  });

  SentryConfigurationCache? configuration;
  SentryUserCache? user;
  int userReads = 0;

  @override
  Future<SentryConfigurationCache> getSentryConfiguration() async {
    if (configuration == null) throw StateError('config not found');
    return configuration!;
  }

  @override
  Future<SentryUserCache> getSentryUser() async {
    userReads++;
    if (user == null) throw StateError('user not found');
    return user!;
  }

  @override
  Future<void> saveSentryConfiguration(
    SentryConfigurationCache sentryConfigurationCache,
  ) async {}

  @override
  Future<void> saveSentryUser(SentryUserCache sentryUserCache) async {}

  @override
  Future<SentryConfigurationCache?> updateSentryReportingAllowed(
    bool isReportingAllowed,
  ) async =>
      null;

  @override
  Future<void> clearSentryConfiguration() async {}
}

class _FakeSentryRuntime extends FcmSentryRuntime {
  _FakeSentryRuntime({
    this.onInitialize,
    this.onSetReportingConsent,
    bool isAvailable = false,
  }) : _isAvailable = isAvailable;

  final Future<void> Function()? onInitialize;
  final Future<void> Function(bool? consent)? onSetReportingConsent;
  bool _isAvailable;
  final consents = <bool?>[];
  final initializedConfigs = <SentryConfig>[];
  final users = <SentryUser>[];
  SentryUser? currentUser;
  int clearUserCalls = 0;

  @override
  bool get isAvailable => _isAvailable;

  @override
  Future<void> setReportingConsent(bool? consent) async {
    consents.add(consent);
    if (consent == false) _isAvailable = false;
    await onSetReportingConsent?.call(consent);
    if (consent == true) _isAvailable = true;
  }

  @override
  Future<void> initialize(SentryConfig sentryConfig) async {
    initializedConfigs.add(sentryConfig);
    await onInitialize?.call();
  }

  @override
  void setUser(SentryUser user) {
    currentUser = user;
    users.add(user);
  }

  @override
  void clearUser() {
    currentUser = null;
    clearUserCalls++;
  }
}

SentryConfigurationCache _configuration({
  required bool isAvailable,
  required bool isReportingAllowed,
  String release = '1.0.0',
}) =>
    SentryConfigurationCache(
      dsn: 'https://test@sentry.io/123',
      environment: 'test',
      release: release,
      tracesSampleRate: 0.1,
      profilesSampleRate: 0.1,
      enableLogs: true,
      isDebug: false,
      attachScreenshot: false,
      isAvailable: isAvailable,
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
  test('background isolate does not initialize Sentry without consent', () async {
    final cacheManager = _FakeCacheManager(configuration: _configuration(
      isAvailable: true,
      isReportingAllowed: false,
    ));
    final sentryRuntime = _FakeSentryRuntime();

    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );

    expect(sentryRuntime.consents, [false]);
    expect(sentryRuntime.clearUserCalls, 1);
    expect(sentryRuntime.initializedConfigs, isEmpty);
    expect(cacheManager.userReads, 0);
  });

  test('initializes Sentry and restores the cached user when reporting is allowed', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(
        isAvailable: true,
        isReportingAllowed: true,
      ),
      user: _user('account-a'),
    );
    final sentryRuntime = _FakeSentryRuntime();

    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );

    expect(sentryRuntime.consents, [false, true]);
    expect(sentryRuntime.initializedConfigs, hasLength(1));
    expect(sentryRuntime.initializedConfigs.single.isReportingAllowed, isTrue);
    expect(sentryRuntime.users.single.id, 'account-a');
  });

  test('reuses a running Sentry SDK when the cached config is unchanged', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(
        isAvailable: true,
        isReportingAllowed: true,
      ),
      user: _user('account-a'),
    );
    final sentryRuntime = _FakeSentryRuntime();

    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );
    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );

    expect(sentryRuntime.consents, [false, true]);
    expect(sentryRuntime.initializedConfigs, hasLength(1));
    expect(sentryRuntime.clearUserCalls, 2);
    expect(cacheManager.userReads, 2);
  });

  test('reinitializes a running Sentry SDK when the cached config changes', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(
        isAvailable: true,
        isReportingAllowed: true,
      ),
      user: _user('account-a'),
    );
    final sentryRuntime = _FakeSentryRuntime();

    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );
    cacheManager.configuration = _configuration(
      isAvailable: true,
      isReportingAllowed: true,
      release: '2.0.0',
    );
    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );

    expect(sentryRuntime.consents, [false, true, false, true]);
    expect(
      sentryRuntime.initializedConfigs.map((config) => config.release),
      ['1.0.0', '2.0.0'],
    );
  });

  test('clears a stale user without restarting an unchanged running SDK', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(
        isAvailable: true,
        isReportingAllowed: true,
      ),
      user: _user('account-a'),
    );
    final sentryRuntime = _FakeSentryRuntime();

    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );
    cacheManager.user = null;
    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );

    expect(sentryRuntime.consents, [false, true]);
    expect(sentryRuntime.initializedConfigs, hasLength(1));
    expect(sentryRuntime.clearUserCalls, 2);
    expect(sentryRuntime.users, hasLength(1));
    expect(sentryRuntime.currentUser, isNull);
  });

  test('closes a running Sentry SDK when the cached config becomes unreadable', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(
        isAvailable: true,
        isReportingAllowed: true,
      ),
      user: _user('account-a'),
    );
    final sentryRuntime = _FakeSentryRuntime();

    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );
    cacheManager.configuration = null;
    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );

    expect(sentryRuntime.consents, [false, true, false]);
    expect(sentryRuntime.initializedConfigs, hasLength(1));
    expect(sentryRuntime.isAvailable, isFalse);
  });

  test('does not initialize Sentry when the cached config is unavailable', () async {
    final cacheManager = _FakeCacheManager(configuration: _configuration(
      isAvailable: false,
      isReportingAllowed: true,
    ));
    final sentryRuntime = _FakeSentryRuntime();

    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );

    expect(sentryRuntime.consents, [false]);
    expect(sentryRuntime.clearUserCalls, 1);
    expect(sentryRuntime.initializedConfigs, isEmpty);
    expect(cacheManager.userReads, 0);
  });

  test('does not initialize Sentry when the config is not cached', () async {
    final cacheManager = _FakeCacheManager();
    final sentryRuntime = _FakeSentryRuntime();

    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );

    expect(sentryRuntime.consents, [false]);
    expect(sentryRuntime.clearUserCalls, 1);
    expect(sentryRuntime.initializedConfigs, isEmpty);
    expect(cacheManager.userReads, 0);
  });

  test('initializes Sentry without identity when the user is not cached', () async {
    final cacheManager = _FakeCacheManager(configuration: _configuration(
      isAvailable: true,
      isReportingAllowed: true,
    ));
    final sentryRuntime = _FakeSentryRuntime();

    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );

    expect(sentryRuntime.initializedConfigs, hasLength(1));
    expect(sentryRuntime.users, isEmpty);
    expect(cacheManager.userReads, 1);
  });

  test('re-reads consent and fails closed for a later push', () async {
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(
        isAvailable: true,
        isReportingAllowed: true,
      ),
      user: _user('account-a'),
    );
    final sentryRuntime = _FakeSentryRuntime();

    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );
    cacheManager.configuration = _configuration(
      isAvailable: true,
      isReportingAllowed: false,
    );
    await FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );

    expect(sentryRuntime.consents, [false, true, false]);
    expect(sentryRuntime.initializedConfigs, hasLength(1));
    expect(sentryRuntime.clearUserCalls, 2);
    expect(cacheManager.userReads, 1);
  });

  test('does not enable Sentry when consent changes during setup', () async {
    final initializeStarted = Completer<void>();
    final finishInitialize = Completer<void>();
    final cacheManager = _FakeCacheManager(
      configuration: _configuration(
        isAvailable: true,
        isReportingAllowed: true,
      ),
      user: _user('account-a'),
    );
    final sentryRuntime = _FakeSentryRuntime(
      onInitialize: () async {
        initializeStarted.complete();
        await finishInitialize.future;
      },
    );

    final setup = FcmMessageController.instance.setUpSentryConfiguration(
      cacheManager: cacheManager,
      sentryRuntime: sentryRuntime,
    );
    await initializeStarted.future;
    cacheManager.configuration = _configuration(
      isAvailable: true,
      isReportingAllowed: false,
    );
    finishInitialize.complete();
    await setup;

    expect(sentryRuntime.consents, [false, false]);
    expect(sentryRuntime.initializedConfigs, hasLength(1));
  });

  test(
    'does not enable Sentry when setup is cancelled during initialization',
    () async {
      final initializeStarted = Completer<void>();
      final finishInitialize = Completer<void>();
      final cacheManager = _FakeCacheManager(
        configuration: _configuration(
          isAvailable: true,
          isReportingAllowed: true,
        ),
        user: _user('account-a'),
      );
      final sentryRuntime = _FakeSentryRuntime(
        onInitialize: () async {
          initializeStarted.complete();
          await finishInitialize.future;
        },
      );
      final cancellation = FcmSentrySetupCancellation();

      final setup = FcmMessageController.instance.setUpSentryConfiguration(
        cacheManager: cacheManager,
        sentryRuntime: sentryRuntime,
        cancellation: cancellation,
      );
      await initializeStarted.future;
      final invalidation = FcmMessageController.instance.invalidateSentrySetup(
        cancellation,
        sentryRuntime: sentryRuntime,
      );
      await invalidation;
      finishInitialize.complete();
      await setup;

      expect(cancellation.isCancelled, isTrue);
      expect(sentryRuntime.consents, [false, false, false]);
      expect(sentryRuntime.consents.last, isFalse);
    },
  );

  test(
    'revokes a consent transition that completes after cancellation',
    () async {
      final enableStarted = Completer<void>();
      final finishEnable = Completer<void>();
      final cacheManager = _FakeCacheManager(
        configuration: _configuration(
          isAvailable: true,
          isReportingAllowed: true,
        ),
        user: _user('account-a'),
      );
      final sentryRuntime = _FakeSentryRuntime(
        onSetReportingConsent: (consent) async {
          if (consent == true) {
            enableStarted.complete();
            await finishEnable.future;
          }
        },
      );
      final cancellation = FcmSentrySetupCancellation();

      final setup = FcmMessageController.instance.setUpSentryConfiguration(
        cacheManager: cacheManager,
        sentryRuntime: sentryRuntime,
        cancellation: cancellation,
      );
      await enableStarted.future;
      final invalidation = FcmMessageController.instance.invalidateSentrySetup(
        cancellation,
        sentryRuntime: sentryRuntime,
      );
      await invalidation;
      finishEnable.complete();
      await setup;

      expect(sentryRuntime.consents, [false, true, false, false]);
      expect(sentryRuntime.consents.last, isFalse);
      expect(sentryRuntime.clearUserCalls, 3);
    },
  );
}
