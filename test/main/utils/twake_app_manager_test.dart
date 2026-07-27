import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';

void main() {
  late TwakeAppManager twakeAppManager;

  setUp(() {
    twakeAppManager = TwakeAppManager();
  });

  group('[runClearDataOnce]', () {
    test('should run the teardown once when callers arrive concurrently',
        () async {
      // A 401 makes every controller with a pending request start its own
      // logout, and each one clears the Hive boxes then closes Hive.
      var runs = 0;
      final gate = Completer<void>();

      final callers = [
        for (var i = 0; i < 5; i++)
          twakeAppManager.runClearDataOnce(() async {
            runs++;
            await gate.future;
          }),
      ];
      gate.complete();
      await Future.wait(callers);

      expect(runs, equals(1));
    });

    test('should give every concurrent caller the same future', () async {
      final gate = Completer<void>();
      Future<void> clearData() => gate.future;

      final first = twakeAppManager.runClearDataOnce(clearData);
      final second = twakeAppManager.runClearDataOnce(clearData);

      expect(identical(first, second), isTrue);
      gate.complete();
      await Future.wait([first, second]);
    });

    test('should run again once the previous teardown has finished', () async {
      var runs = 0;
      Future<void> clearData() async => runs++;

      await twakeAppManager.runClearDataOnce(clearData);
      await twakeAppManager.runClearDataOnce(clearData);

      expect(runs, equals(2), reason: 'the guard is per teardown, not per app');
    });

    test('should release the guard when the teardown throws', () async {
      // Otherwise one failed teardown wedges logout for the whole session.
      var runs = 0;
      Future<void> failingClearData() async {
        runs++;
        throw StateError('cannot clear all data');
      }

      await expectLater(
        twakeAppManager.runClearDataOnce(failingClearData),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        twakeAppManager.runClearDataOnce(failingClearData),
        throwsA(isA<StateError>()),
      );

      expect(runs, equals(2));
    });

    test('should surface the failure to every concurrent caller', () async {
      final gate = Completer<void>();
      Future<void> failingClearData() async {
        await gate.future;
        throw StateError('cannot clear all data');
      }

      final first = twakeAppManager.runClearDataOnce(failingClearData);
      final second = twakeAppManager.runClearDataOnce(failingClearData);
      gate.complete();

      await expectLater(first, throwsA(isA<StateError>()));
      await expectLater(second, throwsA(isA<StateError>()));
    });
  });
}
