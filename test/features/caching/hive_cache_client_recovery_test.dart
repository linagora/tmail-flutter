@TestOn('vm')

import 'dart:async';
import 'dart:io';

import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';

const _tableName = 'RecoveryTestCache';
const _key = 'key';
const _value = 'value';

/// Blink's wording when an operation lands on a connection that is mid-close.
final _blinkClosingError = StateError(
  "InvalidStateError: Failed to execute 'transaction' on 'IDBDatabase': "
  'The database connection is closing.',
);

/// Gecko's wording for the same condition. Sentry groups the two because the
/// Dart frames are identical, so recovery has to recognise both.
final _geckoClosedError = StateError(
  "InvalidStateError: IDBDatabase.transaction: Can't start a transaction on a "
  'closed database',
);

/// Drives [HiveCacheClient]'s recovery path without a browser.
///
/// `_runWithRecovery` re-acquires the box *inside* the retried closure, so
/// throwing from [openBox] reproduces a dead IndexedDB connection exactly:
/// detect -> recover -> retry. Everything else runs the real Hive backend.
class _RecordingCacheClient extends HiveCacheClient<String> {
  _RecordingCacheClient({Object? errorToThrow})
      : errorToThrow = errorToThrow ?? _blinkClosingError;

  final Object errorToThrow;

  int failuresToInject = 0;

  int openAttempts = 0;
  int closeBoxCalls = 0;
  final List<Box<String>> openedBoxes = [];

  /// Held by the test to force the destructive interleaving: every close after
  /// the first waits here, so it can only land *after* another caller has
  /// already reopened the box. Left null when ordering does not matter.
  Completer<void>? laterClosesGate;

  /// Completes as soon as a box is opened. Reset when arming so it signals the
  /// reopen that follows an injected failure, not the one done while seeding.
  Completer<void> boxOpened = Completer<void>();

  /// Holds back the second injected failure so it can surface *after* another
  /// caller's recovery has already finished — the only order in which a caller
  /// can find the box it failed on already replaced. Left null when ordering
  /// does not matter.
  Completer<void>? secondFailureGate;

  /// Runs just before an injected failure is thrown, so a test can make the
  /// world change *underneath* an operation that is already in flight.
  Future<void> Function()? beforeFailure;

  int _failuresInjected = 0;

  @override
  String get tableName => _tableName;

  @override
  Future<Box<String>> openBox() async {
    openAttempts++;
    if (failuresToInject > 0) {
      failuresToInject--;
      _failuresInjected++;
      if (_failuresInjected == 2 && secondFailureGate != null) {
        await secondFailureGate!.future;
      }
      await beforeFailure?.call();
      throw errorToThrow;
    }
    final box = await super.openBox();
    openedBoxes.add(box);
    if (!boxOpened.isCompleted) boxOpened.complete();
    return box;
  }

  @override
  Future<void> closeBox({bool isolated = true}) async {
    closeBoxCalls++;
    if (closeBoxCalls > 1 && laterClosesGate != null) {
      await laterClosesGate!.future;
    }
    return super.closeBox(isolated: isolated);
  }
}

void main() {
  setUpAll(() async {
    // Recovery is gated on web: IndexedDB is the only backend that can lose a
    // connection while Hive still holds the box. These tests run on the VM to
    // get a real Hive backend, so they have to declare the platform they are
    // standing in for.
    PlatformInfo.isTestingForWeb = true;
    await HiveCacheConfig.instance.setUp(
      cachePath: Directory.current.path,
      isolated: false,
    );
  });

  tearDownAll(() {
    PlatformInfo.isTestingForWeb = false;
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_tableName);
  });

  /// Seeds the box, then arms [client] so its next operations fail the way a
  /// dead connection does. Clears the recorded boxes so assertions only see
  /// what the recovery reopened.
  Future<void> seedThenArm(
    _RecordingCacheClient client, {
    required int failures,
  }) async {
    await client.insertItem(_key, _value, isolated: false);
    client.openedBoxes.clear();
    client.openAttempts = 0;
    client.boxOpened = Completer<void>();
    client.failuresToInject = failures;
  }

  group('[recovery]', () {
    test('should reopen the box and return the value '
        'when the connection closed underneath a read', () async {
      final client = _RecordingCacheClient();
      await seedThenArm(client, failures: 1);

      final result = await client.getItem(_key, isolated: false);

      expect(result, equals(_value));
      expect(client.closeBoxCalls, equals(1));
      expect(client.openAttempts, equals(2));
    });

    test('should recover when the browser reports the Gecko wording', () async {
      final client = _RecordingCacheClient(errorToThrow: _geckoClosedError);
      await seedThenArm(client, failures: 1);

      final result = await client.getItem(_key, isolated: false);

      expect(result, equals(_value));
      expect(client.closeBoxCalls, equals(1));
    });

    test('should recover on the DOMException name alone, '
        'whatever wording the browser gives the message', () async {
      // The name is fixed by WebIDL; the message is engine prose we cannot
      // rely on. This is the generic rendering, with neither known phrase.
      final client = _RecordingCacheClient(
        errorToThrow: StateError(
          'InvalidStateError: The object is in an invalid state.',
        ),
      );
      await seedThenArm(client, failures: 1);

      final result = await client.getItem(_key, isolated: false);

      expect(result, equals(_value));
      expect(client.closeBoxCalls, equals(1));
    });

    test('should recover a write the same way as a read', () async {
      final client = _RecordingCacheClient();
      await seedThenArm(client, failures: 1);

      await client.insertItem(_key, 'updated', isolated: false);

      expect(await client.getItem(_key, isolated: false), equals('updated'));
      expect(client.closeBoxCalls, equals(1));
    });
  });

  group('[concurrent recovery]', () {
    test('should run one recovery only, and never close a box '
        'another caller has just reopened', () async {
      final client = _RecordingCacheClient();
      // Every concurrent caller fails once, so each one enters recovery.
      await seedThenArm(client, failures: 5);

      // Force the damaging order rather than hoping for it: hold back every
      // close after the first until a caller has already reopened the box. An
      // unserialised recovery then closes that live box out from under the
      // callers still using it, which is the production failure.
      client.laterClosesGate = Completer<void>();

      final pendingReads = [
        for (var i = 0; i < 5; i++) client.getItem(_key, isolated: false),
      ];
      await client.boxOpened.future;
      client.laterClosesGate!.complete();

      final results = await Future.wait(pendingReads);

      expect(results, everyElement(equals(_value)));

      // Asserted first because it is the property the bug actually violates:
      // no straggler closed the box the recovery had reopened, so every retry
      // saw one and the same live connection and it is still open at the end.
      expect(client.openedBoxes, hasLength(5));
      expect(
        client.openedBoxes.every((box) => identical(box, client.openedBoxes.first)),
        isTrue,
        reason: 'every retry must see the one box the recovery reopened',
      );
      expect(Hive.isBoxOpen(_tableName), isTrue);

      expect(client.closeBoxCalls, equals(1),
          reason: 'the 5 callers must share a single recovery');
    });

    test('should not close a box a recovery that already finished '
        'had just reopened', () async {
      final client = _RecordingCacheClient();
      await seedThenArm(client, failures: 2);

      // The shared future only spans the close, so it is empty again by the
      // time the first caller retries. A straggler failing in that window used
      // to install a second recovery and close the live box back out.
      client.secondFailureGate = Completer<void>();

      final firstRead = client.getItem(_key, isolated: false);
      final stragglerRead = client.getItem(_key, isolated: false);

      // Let the first caller recover and retry before the straggler fails.
      expect(await firstRead, equals(_value));
      client.secondFailureGate!.complete();

      expect(await stragglerRead, equals(_value));

      expect(client.closeBoxCalls, equals(1),
          reason: 'the box was already replaced, so there was nothing to close');
      expect(
        client.openedBoxes.every((box) => identical(box, client.openedBoxes.first)),
        isTrue,
        reason: 'the straggler must retry against the reopened box',
      );
      expect(Hive.isBoxOpen(_tableName), isTrue);
    });
  });

  group('[non-recoverable errors]', () {
    test('should rethrow an unrelated error without touching the box', () async {
      final client = _RecordingCacheClient(
        errorToThrow: StateError('some other failure'),
      );
      await seedThenArm(client, failures: 1);

      await expectLater(
        client.getItem(_key, isolated: false),
        throwsA(isA<StateError>()),
      );
      expect(client.closeBoxCalls, equals(0));
      expect(client.openAttempts, equals(1), reason: 'must not retry');
    });

    test('should not recover "Box has already been closed", '
        'which also means a deliberate logout teardown', () async {
      final client = _RecordingCacheClient(
        errorToThrow: HiveError('Box has already been closed.'),
      );
      await seedThenArm(client, failures: 1);

      await expectLater(
        client.getItem(_key, isolated: false),
        throwsA(isA<HiveError>()),
      );
      expect(client.closeBoxCalls, equals(0));
    });

    test('should not reopen a box that logout closed on purpose', () async {
      final client = _RecordingCacheClient();
      await seedThenArm(client, failures: 1);

      // What logout does: Hive.close() unregisters every box before closing
      // its backend, so a write racing the teardown sees an unregistered box.
      await Hive.close();
      expect(Hive.isBoxOpen(_tableName), isFalse);

      await expectLater(
        client.insertItem(_key, 'written after logout', isolated: false),
        throwsA(isA<StateError>()),
      );

      // Nothing resurrected the box, so no post-logout data can reach the
      // next session through it.
      expect(Hive.isBoxOpen(_tableName), isFalse);
      expect(client.closeBoxCalls, equals(0));
      expect(client.openAttempts, equals(1), reason: 'must not retry');
    });

    test('should not retry a write that spans a logout, even when the box '
        'was reopened in the meantime', () async {
      final client = _RecordingCacheClient();
      await seedThenArm(client, failures: 1);

      // The interleaving the registered/unregistered check cannot see: logout
      // clears the boxes and closes Hive, and the login page the app navigates
      // to immediately reopens one. By the time the in-flight write fails, the
      // box reads as open again — so only the close count still shows what
      // happened.
      client.beforeFailure = () async {
        await Hive.box<String>(_tableName).clear();
        await HiveCacheConfig.instance.closeHive(isolated: false);
        await Hive.openBox<String>(_tableName);
      };

      await expectLater(
        client.insertItem(_key, 'written before logout', isolated: false),
        throwsA(isA<StateError>()),
      );

      expect(client.closeBoxCalls, equals(0));
      expect(client.openAttempts, equals(1), reason: 'must not retry');

      // The point of the guard: nothing from before the logout survived into
      // the box the next session will use.
      expect(Hive.isBoxOpen(_tableName), isTrue);
      expect(Hive.box<String>(_tableName).get(_key), isNull);
    });

    test('should not recover off web, where there is no IndexedDB '
        'to lose a connection', () async {
      final client = _RecordingCacheClient();
      await seedThenArm(client, failures: 1);
      PlatformInfo.isTestingForWeb = false;
      addTearDown(() => PlatformInfo.isTestingForWeb = true);

      await expectLater(
        client.getItem(_key, isolated: false),
        throwsA(isA<StateError>()),
      );

      // Mobile and desktop keep the pre-recovery behaviour exactly: the error
      // surfaces, and nothing closes a box the classifier only matched on a
      // substring.
      expect(client.closeBoxCalls, equals(0));
      expect(client.openAttempts, equals(1), reason: 'must not retry');
    });

    test('should retry once only when the connection stays dead', () async {
      final client = _RecordingCacheClient();
      await seedThenArm(client, failures: 99);

      await expectLater(
        client.getItem(_key, isolated: false),
        throwsA(isA<StateError>()),
      );
      expect(client.openAttempts, equals(2), reason: 'one attempt, one retry');
      expect(client.closeBoxCalls, equals(1));
    });
  });
}
