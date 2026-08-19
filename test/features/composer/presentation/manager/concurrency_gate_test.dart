import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/concurrency_gate.dart';

// Runs [items] through [gate] and asserts every one was processed exactly once.
Future<void> expectAllItemsProcessed(ConcurrencyGate gate, List<int> items) async {
  final processed = <int>[];

  await Future.wait(items.map((item) => gate.run(() async {
        await Future<void>.delayed(Duration.zero);
        processed.add(item);
      })));

  expect(processed.toSet(), items.toSet());
  expect(processed, hasLength(items.length));
}

// Runs [items] through [gate] while tracking concurrency, returning the peak.
Future<int> peakInFlight(ConcurrencyGate gate, List<int> items) async {
  var inFlight = 0;
  var maxInFlight = 0;

  await Future.wait(items.map((item) => gate.run(() async {
        inFlight++;
        maxInFlight = maxInFlight < inFlight ? inFlight : maxInFlight;
        await Future<void>.delayed(Duration.zero);
        inFlight--;
      })));

  return maxInFlight;
}

void main() {
  group('ConcurrencyGate::run::', () {
    test('Should run every action when they outnumber maxConcurrent', () async {
      await expectAllItemsProcessed(ConcurrencyGate(3), List.generate(10, (index) => index));
    });

    test('Should run every action when they fit in one wave', () async {
      await expectAllItemsProcessed(ConcurrencyGate(5), [0, 1]);
    });

    test('Should return the action result to its own caller', () async {
      final gate = ConcurrencyGate(1);

      final results = await Future.wait([
        gate.run(() async => 'a'),
        gate.run(() async => 'b'),
      ]);

      expect(results, ['a', 'b']);
    });

    test('Should never run more than maxConcurrent actions at once', () async {
      expect(await peakInFlight(ConcurrencyGate(2), List.generate(5, (index) => index)), 2);
    });

    test('Should clamp a maxConcurrent below 1 to a single slot', () async {
      expect(ConcurrencyGate(0).maxConcurrent, 1);
      expect(ConcurrencyGate(-3).maxConcurrent, 1);
      expect(await peakInFlight(ConcurrencyGate(0), [0, 1, 2]), 1);
    });

    test('Should hold later actions until a slot frees', () async {
      final gate = ConcurrencyGate(2);
      final started = <int>[];
      final blockers = List.generate(3, (_) => Completer<void>());

      final futures = List.generate(
        3,
        (index) => gate.run(() async {
          started.add(index);
          await blockers[index].future;
        }),
      );

      await Future<void>.delayed(Duration.zero);
      expect(started, [0, 1]);

      blockers[0].complete();
      await Future<void>.delayed(Duration.zero);
      expect(started, [0, 1, 2]);

      blockers[1].complete();
      blockers[2].complete();
      await Future.wait(futures);
    });

    test('Should propagate a thrown action error to its caller', () async {
      await expectLater(
        ConcurrencyGate(1).run(() async => throw StateError('action blew up')),
        throwsA(isA<StateError>()),
      );
    });

    test('Should release the slot when an action throws', () async {
      final gate = ConcurrencyGate(1);

      await expectLater(
        gate.run(() async => throw StateError('action blew up')),
        throwsA(isA<StateError>()),
      );

      expect(gate.inFlight, 0);
      expect(await gate.run(() async => 'still usable'), 'still usable');
    });
  });
}
