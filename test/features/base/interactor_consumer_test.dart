import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/base/interactor_consumer.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';

import 'interactor_consumer_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UrgentExceptionHandler>()])
class _Consumer with InteractorConsumer {}

class _TestFailure extends FeatureFailure {
  _TestFailure({super.exception});
}

class _TestSuccess extends Success {
  @override
  List<Object?> get props => [];
}

class _UrgentException implements Exception {}

void main() {
  late MockUrgentExceptionHandler handler;
  late _Consumer consumer;

  void expectNeverRouted() => verifyNever(handler.handleUrgentException(
        failure: anyNamed('failure'),
        exception: anyNamed('exception'),
      ));

  setUp(() {
    handler = MockUrgentExceptionHandler();
    Get.put<UrgentExceptionHandler>(handler);
    consumer = _Consumer();
  });

  tearDown(Get.reset);

  group('InteractorConsumer.consumeInteractor', () {
    test('dispatches a terminal success to onSuccess', () async {
      final success = _TestSuccess();
      Success? received;

      await consumer.consumeInteractor(
        () async => Right(success),
        isStale: () => false,
        onSuccess: (s) => received = s,
        onFailure: (_, __) => fail('should not fail'),
      );

      expect(received, success);
      expectNeverRouted();
    });

    test('routes an urgent Left failure, then calls onFailure', () async {
      final exception = _UrgentException();
      final failure = _TestFailure(exception: exception);
      when(handler.validateUrgentException(exception)).thenReturn(true);
      Object? failed;

      await consumer.consumeInteractor(
        () async => Left(failure),
        isStale: () => false,
        onSuccess: (_) => fail('should not succeed'),
        onFailure: (error, _) => failed = error,
      );

      expect(failed, failure);
      verify(handler.handleUrgentException(
        failure: failure,
        exception: exception,
      )).called(1);
    });

    test('routes a thrown error, then calls onFailure', () async {
      final exception = _UrgentException();
      when(handler.validateUrgentException(exception)).thenReturn(true);
      Object? failed;

      await consumer.consumeInteractor(
        () async => throw exception,
        isStale: () => false,
        onSuccess: (_) => fail('should not succeed'),
        onFailure: (error, _) => failed = error,
      );

      expect(failed, exception);
      verify(handler.handleUrgentException(
        failure: null,
        exception: exception,
      )).called(1);
    });

    test('drops a stale result — neither dispatches nor routes', () async {
      when(handler.validateUrgentException(any)).thenReturn(true);
      var dispatched = false;

      await consumer.consumeInteractor(
        () async => Left(_TestFailure(exception: _UrgentException())),
        isStale: () => true,
        onSuccess: (_) => dispatched = true,
        onFailure: (_, __) => dispatched = true,
      );

      expect(dispatched, isFalse);
      expectNeverRouted();
    });

    test('a non-urgent failure calls onFailure without routing', () async {
      final exception = _UrgentException();
      when(handler.validateUrgentException(exception)).thenReturn(false);
      var failedCalled = false;

      await consumer.consumeInteractor(
        () async => Left(_TestFailure(exception: exception)),
        isStale: () => false,
        onSuccess: (_) => fail('should not succeed'),
        onFailure: (_, __) => failedCalled = true,
      );

      expect(failedCalled, isTrue);
      expectNeverRouted();
    });

    test('an error thrown by onSuccess propagates, not misclassified as a '
        'failure', () async {
      when(handler.validateUrgentException(any)).thenReturn(true);
      final bug = StateError('bug in onSuccess');

      await expectLater(
        consumer.consumeInteractor(
          () async => Right(_TestSuccess()),
          isStale: () => false,
          onSuccess: (_) => throw bug,
          onFailure: (_, __) => fail('onSuccess bug must not become a failure'),
        ),
        throwsA(same(bug)),
      );
      expectNeverRouted(); // must not urgent-route a rendering/state bug
    });
  });
}
