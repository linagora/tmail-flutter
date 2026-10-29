import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_load.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/shown_account_load_tracker.dart';

ShownAccountLoad _load(int attemptId, Completer<ShownAccountLoadResult> result) =>
    ShownAccountLoad(attemptId: attemptId, result: result.future);

Future<bool> _isDone(Future<void> future) async {
  var done = false;
  unawaited(future.then((_) => done = true, onError: (_) => done = true));
  await pumpEventQueue();
  return done;
}

void main() {
  late ShownAccountLoadTracker tracker;
  late Completer<ShownAccountLoadResult> folders;
  late Completer<ShownAccountLoadResult> emailList;

  setUp(() {
    tracker = ShownAccountLoadTracker();
    folders = Completer();
    emailList = Completer();
  });

  test('a switch waits until the folders and the email list they opened are loaded', () async {
    tracker.reportFolders(_load(1, folders));
    final waiting = tracker.waitFor(1);
    tracker.reportEmailList(_load(1, emailList));

    folders.complete(const ShownAccountLoaded());
    expect(await _isDone(waiting), isFalse);

    emailList.complete(const ShownAccountLoaded());
    expect(await _isDone(waiting), isTrue);
  });

  test('a switch waits for folders reported after it started waiting', () async {
    final waiting = tracker.waitFor(1);
    expect(await _isDone(waiting), isFalse);

    tracker.reportFolders(_load(1, folders));
    folders.complete(const ShownAccountLoaded());

    expect(await _isDone(waiting), isTrue);
  });

  test('a switch ends with the folders when they opened no email list', () async {
    tracker.reportFolders(_load(1, folders));
    folders.complete(const ShownAccountLoaded());

    await expectLater(tracker.waitFor(1), completes);
  });

  test('failed folders fail the switch with their error', () async {
    tracker.reportFolders(_load(1, folders));
    folders.complete(const ShownAccountLoadFailed('folders failed'));

    await expectLater(
      tracker.waitFor(1),
      throwsA(isA<ShownAccountLoadException>().having((e) => e.error, 'error', 'folders failed')),
    );
  });

  test('a failed load fails the switch with the stack trace where it failed', () async {
    final origin = StackTrace.fromString('origin of the failure');
    tracker.reportFolders(_load(1, folders));
    folders.complete(ShownAccountLoadFailed('folders failed', origin));

    Object? thrown;
    StackTrace? thrownStackTrace;
    try {
      await tracker.waitFor(1);
    } catch (error, stackTrace) {
      thrown = error;
      thrownStackTrace = stackTrace;
    }

    expect(thrown, isA<ShownAccountLoadException>());
    expect(thrownStackTrace, origin);
  });

  test('a failed email list fails the switch with its error', () async {
    tracker.reportFolders(_load(1, folders));
    tracker.reportEmailList(_load(1, emailList));
    folders.complete(const ShownAccountLoaded());
    emailList.complete(const ShownAccountLoadFailed('emails failed'));

    await expectLater(
      tracker.waitFor(1),
      throwsA(isA<ShownAccountLoadException>().having((e) => e.error, 'error', 'emails failed')),
    );
  });

  test('a dropped load ends the wait without failing it', () async {
    tracker.reportFolders(_load(1, folders));
    folders.complete(const ShownAccountLoadDropped());

    await expectLater(tracker.waitFor(1), completes);
  });

  test('a folder load reported again in the same attempt is the one waited for', () async {
    final reloadedFolders = Completer<ShownAccountLoadResult>();
    tracker.reportFolders(_load(1, folders));
    final waiting = tracker.waitFor(1);
    await pumpEventQueue();

    tracker.reportFolders(_load(1, reloadedFolders));
    folders.complete(const ShownAccountLoaded());
    expect(await _isDone(waiting), isFalse);

    reloadedFolders.complete(const ShownAccountLoaded());
    expect(await _isDone(waiting), isTrue);
  });

  test('a load of an older attempt is ignored once a newer one reported', () async {
    final olderFolders = Completer<ShownAccountLoadResult>();
    tracker.reportFolders(_load(2, folders));

    tracker.reportFolders(_load(1, olderFolders));

    expect(tracker.hasFoldersLoad(1), isFalse);
    expect(tracker.hasFoldersLoad(2), isTrue);
  });

  test('waiting for an older attempt returns at once', () async {
    tracker.reportFolders(_load(2, folders));

    await expectLater(tracker.waitFor(1), completes);
  });

  test('a newer attempt forgets the loads of the previous one', () {
    tracker.reportFolders(_load(1, folders));

    tracker.reportEmailList(_load(2, emailList));

    expect(tracker.hasFoldersLoad(1), isFalse);
    expect(tracker.hasFoldersLoad(2), isFalse);
  });

  test('has no folder load for an attempt that reported none', () {
    expect(tracker.hasFoldersLoad(1), isFalse);
  });
}
