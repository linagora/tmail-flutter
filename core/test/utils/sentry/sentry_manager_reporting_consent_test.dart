import 'dart:async';

import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter_test/flutter_test.dart';
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
    test('allows reporting by default, for platforms that publish no default', () {
      expect(sentryManager.isSentryReportingAllowed, isTrue);
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
      var isInitialSync = true;
      final manager = SentryManager.forTesting(
        synchronizeScope: (user, {required clearBreadcrumbs}) {
          synchronizedScopes.add((
            userId: user?.id,
            clearBreadcrumbs: clearBreadcrumbs,
          ));
          if (isInitialSync) {
            isInitialSync = false;
            return Future.value();
          }
          final pendingSync = Completer<void>();
          pendingSyncs.add(pendingSync);
          return pendingSync.future;
        },
      );

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
        (userId: 'alice', clearBreadcrumbs: false),
        (userId: null, clearBreadcrumbs: false),
        (userId: null, clearBreadcrumbs: true),
        (userId: null, clearBreadcrumbs: false),
        (userId: 'bob', clearBreadcrumbs: false),
      ]);
    });

    test('keeps reporting blocked after a scope failure and recovers on the next sync', () async {
      var attempts = 0;
      final manager = SentryManager.forTesting(
        synchronizeScope: (_, {required clearBreadcrumbs}) async {
          attempts++;
          if (attempts == 1) throw StateError('scope unavailable');
        },
      );

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
