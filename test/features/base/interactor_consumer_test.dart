import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/base/interactor_consumer.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';

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

  InteractorConsumeRequest request({
    required InteractorCall run,
    required StaleGuard isStale,
    required InteractorSuccessHandler onSuccess,
    required InteractorFailureHandler onFailure,
    ShouldRouteUrgentException? shouldRouteUrgentException,
  }) =>
      InteractorConsumeRequest(
        run: run,
        isStale: isStale,
        onSuccess: onSuccess,
        onFailure: onFailure,
        shouldRouteUrgentException: shouldRouteUrgentException,
      );

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
        request(
          run: () async => Right(success),
          isStale: () => false,
          onSuccess: (s) => received = s,
          onFailure: (_, __) => fail('should not fail'),
        ),
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
        request(
          run: () async => Left(failure),
          isStale: () => false,
          onSuccess: (_) => fail('should not succeed'),
          onFailure: (error, _) => failed = error,
        ),
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
        request(
          run: () async => throw exception,
          isStale: () => false,
          onSuccess: (_) => fail('should not succeed'),
          onFailure: (error, _) => failed = error,
        ),
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
        request(
          run: () async => Left(_TestFailure(exception: _UrgentException())),
          isStale: () => true,
          onSuccess: (_) => dispatched = true,
          onFailure: (_, __) => dispatched = true,
        ),
      );

      expect(dispatched, isFalse);
      expectNeverRouted();
    });

    test('a non-urgent failure calls onFailure without routing', () async {
      final exception = _UrgentException();
      when(handler.validateUrgentException(exception)).thenReturn(false);
      var failedCalled = false;

      await consumer.consumeInteractor(
        request(
          run: () async => Left(_TestFailure(exception: exception)),
          isStale: () => false,
          onSuccess: (_) => fail('should not succeed'),
          onFailure: (_, __) => failedCalled = true,
        ),
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
          request(
            run: () async => Right(_TestSuccess()),
            isStale: () => false,
            onSuccess: (_) => throw bug,
            onFailure: (_, __) =>
                fail('onSuccess bug must not become a failure'),
          ),
        ),
        throwsA(same(bug)),
      );
      expectNeverRouted(); // must not urgent-route a rendering/state bug
    });

    test('shouldRouteUrgentException: false skips routing for a Left failure',
        () async {
      final exception = _UrgentException();
      final failure = _TestFailure(exception: exception);
      when(handler.validateUrgentException(exception)).thenReturn(true);
      Object? failed;

      await consumer.consumeInteractor(
        request(
          run: () async => Left(failure),
          isStale: () => false,
          shouldRouteUrgentException: (_) => false,
          onSuccess: (_) => fail('should not succeed'),
          onFailure: (error, _) => failed = error,
        ),
      );

      expect(failed, failure);
      expectNeverRouted();
    });

    test(
        'shouldRouteUrgentException: false skips routing for a thrown error',
        () async {
      final exception = _UrgentException();
      when(handler.validateUrgentException(exception)).thenReturn(true);
      Object? failed;

      await consumer.consumeInteractor(
        request(
          run: () async => throw exception,
          isStale: () => false,
          shouldRouteUrgentException: (_) => false,
          onSuccess: (_) => fail('should not succeed'),
          onFailure: (error, _) => failed = error,
        ),
      );

      expect(failed, same(exception));
      expectNeverRouted();
    });

    test('shouldRouteUrgentException: true still routes an urgent failure',
        () async {
      final exception = _UrgentException();
      final failure = _TestFailure(exception: exception);
      when(handler.validateUrgentException(exception)).thenReturn(true);
      Object? failed;

      await consumer.consumeInteractor(
        request(
          run: () async => Left(failure),
          isStale: () => false,
          shouldRouteUrgentException: (_) => true,
          onSuccess: (_) => fail('should not succeed'),
          onFailure: (error, _) => failed = error,
        ),
      );

      expect(failed, failure);
      verify(handler.handleUrgentException(
        failure: failure,
        exception: exception,
      )).called(1);
    });

    test('soft-fail filter still invokes onFailure and returns false', () async {
      final exception = _UrgentException();
      final failure = _TestFailure(exception: exception);
      when(handler.validateUrgentException(exception)).thenReturn(true);
      Object? failed;
      StackTrace? failedStack;

      final succeeded = await consumer.consumeInteractor(
        request(
          run: () async => Left(failure),
          isStale: () => false,
          shouldRouteUrgentException: (_) => false,
          onSuccess: (_) => fail('should not succeed'),
          onFailure: (error, stackTrace) {
            failed = error;
            failedStack = stackTrace;
          },
        ),
      );

      expect(succeeded, isFalse);
      expect(failed, failure);
      expect(failedStack, isNotNull);
      expectNeverRouted();
    });

    test('stale throw skips routing even when the filter would allow it',
        () async {
      final exception = _UrgentException();
      when(handler.validateUrgentException(exception)).thenReturn(true);
      var failedCalled = false;

      final succeeded = await consumer.consumeInteractor(
        request(
          run: () async => throw exception,
          isStale: () => true,
          shouldRouteUrgentException: (_) => true,
          onSuccess: (_) => fail('should not succeed'),
          onFailure: (_, __) => failedCalled = true,
        ),
      );

      expect(succeeded, isFalse);
      expect(failedCalled, isFalse);
      expectNeverRouted();
    });

    test('null shouldRouteUrgentException keeps default ADR-0103 routing',
        () async {
      final exception = _UrgentException();
      final failure = _TestFailure(exception: exception);
      when(handler.validateUrgentException(exception)).thenReturn(true);

      await consumer.consumeInteractor(
        request(
          run: () async => Left(failure),
          isStale: () => false,
          shouldRouteUrgentException: null,
          onSuccess: (_) => fail('should not succeed'),
          onFailure: (_, __) {},
        ),
      );

      verify(handler.handleUrgentException(
        failure: failure,
        exception: exception,
      )).called(1);
    });

    test(
        'unwraps FeatureFailure before shouldRouteUrgentException so type-only '
        'filters soft-fail Left carriers', () async {
      const exception = ConnectionError();
      final failure = _TestFailure(exception: exception);
      when(handler.validateUrgentException(exception)).thenReturn(true);
      Object? seenByFilter;

      await consumer.consumeInteractor(
        request(
          run: () async => Left(failure),
          isStale: () => false,
          // Intentionally no FeatureFailure unwrap — seam must normalize.
          shouldRouteUrgentException: (error) {
            seenByFilter = error;
            return error is! ConnectionError && error is! NoNetworkError;
          },
          onSuccess: (_) => fail('should not succeed'),
          onFailure: (_, __) {},
        ),
      );

      expect(seenByFilter, same(exception));
      expectNeverRouted();
    });
  });
}
