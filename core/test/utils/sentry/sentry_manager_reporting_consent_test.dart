import 'dart:async';

import 'package:core/utils/application_manager.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  final sentryManager = SentryManager.instance;

  // The manager is a singleton; reset both inputs so ordering between tests
  // cannot leak.
  setUp(() {
    sentryManager.resumeSentryReporting();
    sentryManager.setSentryReportingDefault(true);
    sentryManager.setSentryReportingConsent(null);
  });

  group('SentryManager reporting consent', () {
    test(
      'valid env config mounts the monitored app before consent arrives',
      () async {
        dotenv.testLoad(
          mergeWith: {
            SentryConfig.enabledEnvKey: 'true',
            SentryConfig.dsnEnvKey: 'https://env@example.com/1',
            SentryConfig.environmentEnvKey: 'test',
          },
        );
        addTearDown(dotenv.clean);
        PackageInfo.setMockInitialValues(
          appName: 'Twake Mail',
          packageName: 'com.example.twake',
          version: '1.0.0',
          buildNumber: '1',
          buildSignature: '',
        );
        ApplicationManager().clearCache();
        addTearDown(ApplicationManager().clearCache);
        var starts = 0;
        var appRuns = 0;
        var fallbackRuns = 0;
        final manager = SentryManager.forTesting(
          isSentryAvailable: false,
          synchronizeScope: (_, {required clearBreadcrumbs}) async {},
          initializeSentrySdk: ({appRunner, sentryConfig}) async {
            starts++;
            return true;
          },
          closeSentrySdk: () async {},
        );

        await manager.initialize(
          appRunner: () {
            appRuns++;
          },
          fallBackRunner: () {
            fallbackRuns++;
          },
        );

        expect(manager.isSentryConfigured, isTrue);
        expect(manager.isSentryReportingAllowed, isFalse);
        expect(manager.isSentryAvailable, isFalse);
        expect(starts, 0);
        expect(appRuns, 1);
        expect(fallbackRuns, 0);

        manager.setSentryReportingDefault(true);
        await manager.pendingLifecycleTransition;

        expect(manager.isSentryAvailable, isTrue);
        expect(starts, 1);
        expect(appRuns, 1);
        expect(fallbackRuns, 0);
      },
    );

    test('web starts from env credentials when SENTRY_ENABLED is true',
        () async {
      _configureWebSentryEnvironment();
      final probe = _WebEnvSentryProbe();

      await probe.start();

      expect(
        probe.snapshot,
        (reportingAllowed: true, sdkAvailable: true, starts: 1, closes: 0),
      );
      expect(
        probe.startupResult,
        (configured: true, configAllowsReporting: true, appRuns: 1, fallbackRuns: 0),
      );
    });

    test('web ecosystem default can stop startup reporting',
        () async {
      _configureWebSentryEnvironment();
      final probe = _WebEnvSentryProbe();
      await probe.start();

      await probe.applyEcosystemDefault(false);

      expect(probe.snapshot,
          (reportingAllowed: false, sdkAvailable: false, starts: 1, closes: 1));
    });

    test('web server consent restarts and stops SDK without rerunning the app',
        () async {
      _configureWebSentryEnvironment();
      final probe = _WebEnvSentryProbe();
      await probe.start();
      await probe.applyEcosystemDefault(false);

      await probe.applyServerConsent(true);
      final allowedState = probe.snapshot;
      await probe.applyServerConsent(false);

      expect([allowedState, probe.snapshot], [
        (reportingAllowed: true, sdkAvailable: true, starts: 2, closes: 1),
        (reportingAllowed: false, sdkAvailable: false, starts: 2, closes: 2),
      ]);
      expect(probe.appRuns, 1);
    });

    test('web disabled env stays off after ecosystem and server opt-in',
        () async {
      _configureWebSentryEnvironment(enabled: 'false');
      final probe = _WebEnvSentryProbe();

      await probe.start();
      await probe.applyEcosystemDefault(true);
      await probe.applyServerConsent(true);

      expect(probe.manager.isSentryConfigured, isFalse);
      expect(probe.startedConfigs, isEmpty);
      expect((probe.appRuns, probe.fallbackRuns), (0, 1));
    });

    test('does not retry app startup when the configured runner fails',
        () async {
      dotenv.testLoad(mergeWith: {
        SentryConfig.enabledEnvKey: 'true',
        SentryConfig.dsnEnvKey: 'https://env@example.com/1',
        SentryConfig.environmentEnvKey: 'test',
      });
      addTearDown(dotenv.clean);
      PackageInfo.setMockInitialValues(
        appName: 'Twake Mail',
        packageName: 'com.example.twake',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
      ApplicationManager().clearCache();
      addTearDown(ApplicationManager().clearCache);
      final manager = SentryManager.forTesting(
        isSentryAvailable: false,
        synchronizeScope: (_, {required clearBreadcrumbs}) async {},
      );
      var appRuns = 0;
      var fallbackRuns = 0;

      await expectLater(
        manager.initialize(
          appRunner: () {
            appRuns++;
            throw StateError('preload failed');
          },
          fallBackRunner: () {
            fallbackRuns++;
          },
        ),
        throwsStateError,
      );

      expect(appRuns, 1);
      expect(fallbackRuns, 0);
      expect(manager.isSentryAvailable, isFalse);
    });

    test(
      'empty env starts the app once and later uses ecosystem config',
      () async {
        dotenv.testLoad(
          mergeWith: {
            SentryConfig.enabledEnvKey: '',
            SentryConfig.dsnEnvKey: ' ',
            SentryConfig.environmentEnvKey: '',
          },
        );
        addTearDown(dotenv.clean);
        final startedConfigs = <SentryConfig>[];
        var closes = 0;
        var appRuns = 0;
        var fallbackRuns = 0;
        final manager = SentryManager.forTesting(
          isSentryAvailable: false,
          synchronizeScope: (_, {required clearBreadcrumbs}) async {},
          initializeSentrySdk: ({appRunner, sentryConfig}) async {
            startedConfigs.add(sentryConfig!);
            return true;
          },
          closeSentrySdk: () async {
            closes++;
          },
        );

        await manager.initialize(
          appRunner: () {
            appRuns++;
          },
          fallBackRunner: () {
            fallbackRuns++;
          },
        );

        expect(fallbackRuns, 1);
        expect(appRuns, 0);
        expect(startedConfigs, isEmpty);
        expect(manager.isSentryConfigured, isFalse);

        await manager.initializeWithSentryConfig(
          SentryConfig(
            dsn: 'https://ecosystem@example.com/1',
            environment: 'staging',
            release: '1.0.0',
            isAvailable: true,
          ),
        );

        expect(manager.isSentryConfigured, isTrue);
        expect(manager.isSentryReportingAllowed, isFalse);
        expect(startedConfigs, isEmpty);

        manager.setSentryReportingDefault(true);
        await manager.pendingLifecycleTransition;

        expect(startedConfigs, hasLength(1));
        expect(startedConfigs.single.dsn, 'https://ecosystem@example.com/1');
        expect(startedConfigs.single.isReportingAllowed, isTrue);
        expect(manager.isSentryAvailable, isTrue);
        expect(fallbackRuns, 1);
        expect(appRuns, 0);

        manager.setSentryReportingConsent(false);
        await manager.pendingLifecycleTransition;

        expect(closes, 1);
        expect(manager.isSentryAvailable, isFalse);

        manager.setSentryReportingConsent(null);
        await manager.pendingLifecycleTransition;

        expect(startedConfigs, hasLength(2));
        expect(fallbackRuns, 1);
        expect(appRuns, 0);
      },
    );

    test('starts denied before either consent source is loaded', () {
      final manager = SentryManager.forTesting(
        isSentryAvailable: false,
        synchronizeScope: (_, {required clearBreadcrumbs}) async {},
      );

      expect(manager.isSentryReportingAllowed, isFalse);
    });

    test('follows the instance default while the user has not chosen', () {
      sentryManager.setSentryReportingDefault(false);

      expect(sentryManager.isSentryReportingAllowed, isFalse);
    });

    test('lets the user opt in on an instance that is off by default', () {
      sentryManager.setSentryReportingDefault(false);

      sentryManager.setSentryReportingConsent(true);

      expect(sentryManager.isSentryReportingAllowed, isTrue);
    });

    test('lets the user opt out on an instance that is on by default', () {
      sentryManager.setSentryReportingDefault(true);

      sentryManager.setSentryReportingConsent(false);

      expect(sentryManager.isSentryReportingAllowed, isFalse);
    });

    test('keeps the user choice when the instance default arrives afterwards', () {
      sentryManager.setSentryReportingConsent(true);

      sentryManager.setSentryReportingDefault(false);

      expect(sentryManager.isSentryReportingAllowed, isTrue);
    });

    test('falls back to the instance default when the choice is cleared', () {
      sentryManager.setSentryReportingDefault(false);
      sentryManager.setSentryReportingConsent(true);

      sentryManager.setSentryReportingConsent(null);

      expect(sentryManager.isSentryReportingAllowed, isFalse);
    });

    test('falls back to the runtime configuration when the ecosystem default is cleared', () async {
      final manager = SentryManager.forTesting(
        isSentryAvailable: false,
        synchronizeScope: (_, {required clearBreadcrumbs}) async {},
        initializeSentrySdk: ({appRunner, sentryConfig}) async => true,
        closeSentrySdk: () async {},
      );
      await manager.initializeWithSentryConfig(SentryConfig(
        dsn: 'https://public@example.com/1',
        environment: 'test',
        release: '1.0.0',
        isAvailable: true,
        isReportingAllowed: true,
      ));

      manager.setSentryReportingDefault(false);
      expect(manager.isSentryReportingAllowed, isFalse);

      manager.clearSentryReportingDefault();
      await manager.pendingLifecycleTransition;

      expect(manager.isSentryReportingAllowed, isTrue);
    });

    test('suspends the SDK without changing the effective user consent', () async {
      var starts = 0;
      var closes = 0;
      final manager = SentryManager.forTesting(
        isSentryAvailable: false,
        synchronizeScope: (_, {required clearBreadcrumbs}) async {},
        initializeSentrySdk: ({appRunner, sentryConfig}) async {
          starts++;
          return true;
        },
        closeSentrySdk: () async {
          closes++;
        },
      );
      await manager.initializeWithSentryConfig(SentryConfig(
        dsn: 'https://public@example.com/1',
        environment: 'test',
        release: '1.0.0',
        isAvailable: true,
        isReportingAllowed: true,
      ));
      manager.setSentryReportingConsent(true);

      manager.suspendSentryReporting();
      await manager.pendingLifecycleTransition;

      expect(manager.isSentryReportingAllowed, isTrue);
      expect(manager.isSentryAvailable, isFalse);
      expect(manager.isSentryReportingReady, isFalse);
      expect(closes, 1);

      manager.resumeSentryReporting();
      await manager.pendingLifecycleTransition;

      expect(manager.isSentryAvailable, isTrue);
      expect(manager.isSentryReportingReady, isTrue);
      expect(starts, 2);
    });

    test('reports configured only while ecosystem ownership is resolved',
        () async {
      final manager = SentryManager.forTesting(
        isSentryAvailable: false,
        synchronizeScope: (_, {required clearBreadcrumbs}) async {},
        initializeSentrySdk: ({appRunner, sentryConfig}) async => true,
        closeSentrySdk: () async {},
      );
      await manager.initializeWithSentryConfig(SentryConfig(
        dsn: 'https://public@example.com/1',
        environment: 'test',
        release: '1.0.0',
        isAvailable: true,
        isReportingAllowed: false,
      ));

      expect(manager.isSentryConfigured, isTrue);

      manager.suspendSentryReporting();
      await manager.pendingLifecycleTransition;

      expect(manager.isSentryConfigured, isFalse);

      manager.resumeSentryReporting();
      await manager.pendingLifecycleTransition;

      expect(manager.isSentryConfigured, isTrue);
    });

    test('a cleared choice falls back to the default, not to the last choice', () {
      sentryManager.setSentryReportingDefault(false);
      sentryManager.setSentryReportingConsent(true);

      // What logout does: the choice belonged to the account that went away.
      sentryManager.setSentryReportingConsent(null);

      expect(sentryManager.isSentryReportingAllowed, isFalse,
          reason: 'the next account must not inherit the previous opt-in');
    });

    test('session cleanup waits for scope and lifecycle reset', () async {
      final finishScopeSync = Completer<void>();
      final finishSdkClose = Completer<void>();
      var blockScopeSync = false;
      ({String? userId, bool clearBreadcrumbs})? blockedScope;
      final manager = SentryManager.forTesting(
        synchronizeScope: (user, {required clearBreadcrumbs}) {
          if (!blockScopeSync) return Future.value();
          blockedScope = (
            userId: user?.id,
            clearBreadcrumbs: clearBreadcrumbs,
          );
          return finishScopeSync.future;
        },
        closeSentrySdk: () => finishSdkClose.future,
      );
      manager.setSentryReportingConsent(true);
      await manager.initializeWithSentryConfig(SentryConfig(
        dsn: 'https://public@example.com/1',
        environment: 'test',
        release: '1.0.0',
        isAvailable: true,
        isReportingAllowed: false,
      ));
      manager.setUser(SentryUser(id: 'account-a'));
      await manager.pendingScopeSync;
      blockScopeSync = true;
      var cleanupCompleted = false;

      final cleanup = manager.clearSessionContext().then((_) {
        cleanupCompleted = true;
      });
      await Future<void>.delayed(Duration.zero);

      expect(manager.isSentryReportingAllowed, isFalse);
      expect(manager.userForScope, isNull);
      expect(blockedScope, (userId: null, clearBreadcrumbs: true));
      expect(cleanupCompleted, isFalse);

      finishScopeSync.complete();
      await Future<void>.delayed(Duration.zero);
      expect(cleanupCompleted, isFalse);

      finishSdkClose.complete();
      await cleanup;

      expect(manager.isSentryAvailable, isFalse);
      expect(cleanupCompleted, isTrue);
    });

    test('reports nothing while Sentry itself never started', () {
      sentryManager.setSentryReportingConsent(true);

      // The capture path also requires the SDK; consent alone sends nothing,
      // and the settings toggle is only offered once this turns true.
      expect(sentryManager.isSentryAvailable, isFalse);
    });

    test('dispatches exception, message and breadcrumb only while reporting is ready', () async {
      final dispatched = <String>[];
      final manager = SentryManager.forTesting(
        synchronizeScope: (_, {required clearBreadcrumbs}) async {},
        captureException: (exception, stackTrace, message, extras, level) async {
          dispatched.add('exception:$exception');
        },
        captureMessage: (message, level, extras) async {
          dispatched.add('message:$message');
        },
        addBreadcrumb: (message, {extras, level = SentryLevel.debug, category}) async {
          dispatched.add('breadcrumb:$message');
        },
      );

      manager.setSentryReportingDefault(true);
      await manager.pendingScopeSync;

      manager.captureException('failure');
      manager.captureMessage('diagnostic');
      manager.addBreadcrumb('navigation');
      await Future<void>.delayed(Duration.zero);

      expect(dispatched, [
        'exception:failure',
        'message:diagnostic',
        'breadcrumb:navigation',
      ]);

      manager.setSentryReportingConsent(false);
      manager.captureException('blocked failure');
      manager.captureMessage('blocked diagnostic');
      manager.addBreadcrumb('blocked navigation');
      await manager.pendingScopeSync;

      expect(dispatched, hasLength(3));
    });
  });

  group('SentryManager SDK lifecycle', () {
    final config = SentryConfig(
      dsn: 'https://public@example.com/1',
      environment: 'test',
      release: '1.0.0',
      isAvailable: true,
      isReportingAllowed: false,
    );

    test('starts and closes the complete SDK when consent changes', () async {
      var starts = 0;
      var closes = 0;
      final manager = SentryManager.forTesting(
        isSentryAvailable: false,
        synchronizeScope: (_, {required clearBreadcrumbs}) async {},
        initializeSentrySdk: ({appRunner, sentryConfig}) async {
          starts++;
          return true;
        },
        closeSentrySdk: () async {
          closes++;
        },
      );

      await manager.initializeWithSentryConfig(config);
      expect(starts, 0);
      expect(manager.isSentryAvailable, isFalse);

      manager.setSentryReportingConsent(true);
      await manager.pendingLifecycleTransition;
      expect(starts, 1);
      expect(manager.isSentryAvailable, isTrue);

      manager.setSentryReportingConsent(false);
      await manager.pendingLifecycleTransition;
      expect(closes, 1);
      expect(manager.isSentryAvailable, isFalse);

      manager.setSentryReportingConsent(true);
      await manager.pendingLifecycleTransition;
      expect(starts, 2);
      expect(manager.isSentryAvailable, isTrue);
    });

    test('closes an initialization that finishes after consent was revoked', () async {
      final initialization = Completer<bool>();
      var closes = 0;
      final manager = SentryManager.forTesting(
        isSentryAvailable: false,
        synchronizeScope: (_, {required clearBreadcrumbs}) async {},
        initializeSentrySdk: ({appRunner, sentryConfig}) => initialization.future,
        closeSentrySdk: () async {
          closes++;
        },
      );

      await manager.initializeWithSentryConfig(config);
      manager.setSentryReportingConsent(true);
      await Future<void>.delayed(Duration.zero);

      manager.setSentryReportingConsent(false);
      initialization.complete(true);
      await manager.pendingLifecycleTransition;

      expect(closes, 1);
      expect(manager.isSentryAvailable, isFalse);
      expect(manager.isSentryReportingReady, isFalse);
    });
  });

  group('SentryManager user scope', () {
    // The ecosystem sets the user at startup, which on an opted-out instance
    // happens before the server settings say what the user chose.
    test('carries no identity while reporting is off', () {
      sentryManager.setSentryReportingDefault(false);

      sentryManager.setUser(SentryUser(id: 'alice'));

      expect(sentryManager.userForScope, isNull);
    });

    test('forgets nothing when reporting is merely off', () {
      sentryManager.setSentryReportingDefault(false);
      sentryManager.setUser(SentryUser(id: 'alice'));

      sentryManager.setSentryReportingDefault(true);

      expect(sentryManager.userForScope?.id, 'alice');
    });

    test('carries the identity set earlier once the user opts in', () {
      sentryManager.setSentryReportingDefault(false);
      sentryManager.setUser(SentryUser(id: 'alice'));

      sentryManager.setSentryReportingConsent(true);

      expect(sentryManager.userForScope?.id, 'alice',
          reason: 'opting in must not lose the identity set beforehand');
    });

    test('drops the identity again when the user opts out', () {
      sentryManager.setSentryReportingConsent(true);
      sentryManager.setUser(SentryUser(id: 'alice'));

      sentryManager.setSentryReportingConsent(false);

      expect(sentryManager.userForScope, isNull);
    });

    test('forgets the identity after clearUser', () {
      sentryManager.setSentryReportingConsent(true);
      sentryManager.setUser(SentryUser(id: 'alice'));

      sentryManager.clearUser();

      expect(sentryManager.userForScope, isNull);
    });

    test('blocks reporting until the latest account scope update completes', () async {
      final pendingSyncs = <Completer<void>>[];
      final synchronizedScopes = <({String? userId, bool clearBreadcrumbs})>[];
      var initialSyncs = 0;
      final manager = SentryManager.forTesting(
        synchronizeScope: (user, {required clearBreadcrumbs}) {
          synchronizedScopes.add((
            userId: user?.id,
            clearBreadcrumbs: clearBreadcrumbs,
          ));
          if (initialSyncs < 2) {
            initialSyncs++;
            return Future.value();
          }
          final pendingSync = Completer<void>();
          pendingSyncs.add(pendingSync);
          return pendingSync.future;
        },
      );

      manager.setSentryReportingDefault(true);
      await manager.pendingScopeSync;

      manager.setUser(SentryUser(id: 'alice'));
      await manager.pendingScopeSync;
      expect(manager.isSentryReportingReady, isTrue);

      manager.clearUser();
      manager.setSentryReportingDefault(false);
      manager.setSentryReportingDefault(true);
      manager.setUser(SentryUser(id: 'bob'));

      expect(manager.isSentryReportingAllowed, isTrue);
      expect(manager.isSentryReportingReady, isFalse);

      for (var index = 0; index < 4; index++) {
        await Future<void>.delayed(Duration.zero);
        expect(pendingSyncs, hasLength(index + 1));
        expect(manager.isSentryReportingReady, isFalse);
        pendingSyncs[index].complete();
      }
      await manager.pendingScopeSync;

      expect(manager.isSentryReportingReady, isTrue);
      expect(synchronizedScopes, [
        (userId: null, clearBreadcrumbs: false),
        (userId: 'alice', clearBreadcrumbs: false),
        (userId: null, clearBreadcrumbs: false),
        (userId: null, clearBreadcrumbs: true),
        (userId: null, clearBreadcrumbs: false),
        (userId: 'bob', clearBreadcrumbs: false),
      ]);
    });

    test('keeps reporting blocked after a scope failure and recovers on the next sync', () async {
      var attempts = 0;
      var failNextSync = false;
      final manager = SentryManager.forTesting(
        synchronizeScope: (_, {required clearBreadcrumbs}) async {
          attempts++;
          if (failNextSync) {
            failNextSync = false;
            throw StateError('scope unavailable');
          }
        },
      );

      manager.setSentryReportingDefault(true);
      await manager.pendingScopeSync;
      attempts = 0;
      failNextSync = true;

      manager.setUser(SentryUser(id: 'alice'));
      await manager.pendingScopeSync;

      expect(manager.isSentryReportingAllowed, isTrue);
      expect(manager.isSentryReportingReady, isFalse);

      manager.setUser(SentryUser(id: 'alice'));
      await manager.pendingScopeSync;

      expect(attempts, 2);
      expect(manager.isSentryReportingReady, isTrue);
    });
  });
}

void _configureWebSentryEnvironment({String enabled = 'true'}) {
  PlatformInfo.isTestingForWeb = true;
  addTearDown(() => PlatformInfo.isTestingForWeb = false);
  dotenv.testLoad(mergeWith: {
    SentryConfig.enabledEnvKey: enabled,
    SentryConfig.dsnEnvKey: 'https://env@example.com/1',
    SentryConfig.environmentEnvKey: 'test',
  });
  addTearDown(dotenv.clean);
  PackageInfo.setMockInitialValues(
    appName: 'Twake Mail',
    packageName: 'com.example.twake',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  ApplicationManager().clearCache();
  addTearDown(ApplicationManager().clearCache);
}

typedef _SentryLifecycleSnapshot = ({
  bool reportingAllowed,
  bool sdkAvailable,
  int starts,
  int closes,
});

class _WebEnvSentryProbe {
  final startedConfigs = <SentryConfig>[];
  int closes = 0;
  int appRuns = 0;
  int fallbackRuns = 0;

  late final SentryManager manager = SentryManager.forTesting(
    isSentryAvailable: false,
    synchronizeScope: (_, {required clearBreadcrumbs}) async {},
    initializeSentrySdk: ({appRunner, sentryConfig}) async {
      startedConfigs.add(sentryConfig!);
      await appRunner?.call();
      return true;
    },
    closeSentrySdk: () async {
      closes++;
    },
  );

  Future<void> start() => manager.initialize(
        appRunner: () {
          appRuns++;
        },
        fallBackRunner: () {
          fallbackRuns++;
        },
      );

  Future<void> applyEcosystemDefault(bool allowed) async {
    manager.setSentryReportingDefault(allowed);
    await manager.pendingLifecycleTransition;
  }

  Future<void> applyServerConsent(bool? consent) async {
    manager.setSentryReportingConsent(consent);
    await manager.pendingLifecycleTransition;
  }

  _SentryLifecycleSnapshot get snapshot => (
        reportingAllowed: manager.isSentryReportingAllowed,
        sdkAvailable: manager.isSentryAvailable,
        starts: startedConfigs.length,
        closes: closes,
      );

  ({bool configured, bool configAllowsReporting, int appRuns, int fallbackRuns})
      get startupResult => (
            configured: manager.isSentryConfigured,
            configAllowsReporting: startedConfigs.single.isReportingAllowed,
            appRuns: appRuns,
            fallbackRuns: fallbackRuns,
          );
}
