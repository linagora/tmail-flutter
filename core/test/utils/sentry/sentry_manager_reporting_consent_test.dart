import 'dart:async';

import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  final sentryManager = SentryManager.instance;

  // The manager is a singleton; reset both inputs so ordering between tests
  // cannot leak.
  setUp(() {
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

    test('a cleared choice falls back to the default, not to the last choice', () {
      sentryManager.setSentryReportingDefault(false);
      sentryManager.setSentryReportingConsent(true);

      // What logout does: the choice belonged to the account that went away.
      sentryManager.setSentryReportingConsent(null);

      expect(sentryManager.isSentryReportingAllowed, isFalse,
          reason: 'the next account must not inherit the previous opt-in');
    });

    test('reports nothing while Sentry itself never started', () {
      sentryManager.setSentryReportingConsent(true);

      // The capture path also requires the SDK; consent alone sends nothing,
      // and the settings toggle is only offered once this turns true.
      expect(sentryManager.isSentryAvailable, isFalse);
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
  });
}
