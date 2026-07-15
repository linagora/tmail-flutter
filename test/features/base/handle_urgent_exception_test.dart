import 'package:core/presentation/state/failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/base/handle_urgent_exception.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';

import 'handle_urgent_exception_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UrgentExceptionHandler>()])
class _TestFeatureFailure extends FeatureFailure {
  _TestFeatureFailure({super.exception});
}

class _PlainFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class _UrgentException implements Exception {}

void main() {
  late MockUrgentExceptionHandler handler;

  setUp(() {
    handler = MockUrgentExceptionHandler();
    Get.put<UrgentExceptionHandler>(handler);
  });

  tearDown(Get.reset);

  group('handleUrgentExceptionIfNeeded', () {
    test('routes and returns true for an urgent bare exception', () {
      final exception = _UrgentException();
      when(handler.validateUrgentException(exception)).thenReturn(true);

      final result = handleUrgentExceptionIfNeeded(exception: exception);

      expect(result, isTrue);
      verify(handler.validateUrgentException(exception)).called(1);
      verify(
        handler.handleUrgentException(failure: null, exception: exception),
      ).called(1);
    });

    test('returns false and does not route a non-urgent exception', () {
      final exception = _UrgentException();
      when(handler.validateUrgentException(exception)).thenReturn(false);

      final result = handleUrgentExceptionIfNeeded(exception: exception);

      expect(result, isFalse);
      verifyNever(
        handler.handleUrgentException(
          failure: anyNamed('failure'),
          exception: anyNamed('exception'),
        ),
      );
    });

    test('unwraps and routes an urgent FeatureFailure.exception', () {
      final exception = _UrgentException();
      final failure = _TestFeatureFailure(exception: exception);
      when(handler.validateUrgentException(exception)).thenReturn(true);

      final result = handleUrgentExceptionIfNeeded(failure: failure);

      expect(result, isTrue);
      verify(
        handler.handleUrgentException(failure: failure, exception: exception),
      ).called(1);
    });

    test('returns false for a FeatureFailure with a non-urgent exception', () {
      final exception = _UrgentException();
      final failure = _TestFeatureFailure(exception: exception);
      when(handler.validateUrgentException(exception)).thenReturn(false);

      expect(handleUrgentExceptionIfNeeded(failure: failure), isFalse);
    });

    test('returns false for a FeatureFailure with no exception', () {
      expect(
        handleUrgentExceptionIfNeeded(failure: _TestFeatureFailure()),
        isFalse,
      );
      verifyNever(handler.validateUrgentException(any));
    });

    test('returns false for a non-FeatureFailure failure', () {
      expect(handleUrgentExceptionIfNeeded(failure: _PlainFailure()), isFalse);
      verifyNever(handler.validateUrgentException(any));
    });

    test('returns false without throwing when no handler is registered', () {
      Get.reset();
      expect(
        handleUrgentExceptionIfNeeded(exception: _UrgentException()),
        isFalse,
      );
    });
  });

  group('isUrgentException', () {
    test('true for an urgent exception, without routing it', () {
      final exception = _UrgentException();
      when(handler.validateUrgentException(exception)).thenReturn(true);

      expect(isUrgentException(exception), isTrue);
      verifyNever(handler.handleUrgentException(
        failure: anyNamed('failure'),
        exception: anyNamed('exception'),
      ));
    });

    test('false for a non-urgent exception', () {
      final exception = _UrgentException();
      when(handler.validateUrgentException(exception)).thenReturn(false);

      expect(isUrgentException(exception), isFalse);
    });

    test('unwraps and validates a FeatureFailure.exception', () {
      final exception = _UrgentException();
      final failure = _TestFeatureFailure(exception: exception);
      when(handler.validateUrgentException(exception)).thenReturn(true);

      expect(isUrgentException(failure), isTrue);
      verify(handler.validateUrgentException(exception)).called(1);
    });

    test('false for a FeatureFailure with no exception', () {
      expect(isUrgentException(_TestFeatureFailure()), isFalse);
      verifyNever(handler.validateUrgentException(any));
    });

    test('false for a non-FeatureFailure failure, mirroring routing', () {
      // A plain Failure carries no exception → never urgent, matching routing.
      expect(isUrgentException(_PlainFailure()), isFalse);
      verifyNever(handler.validateUrgentException(any));
    });

    test('false without throwing when no handler is registered', () {
      Get.reset();
      expect(isUrgentException(_UrgentException()), isFalse);
    });
  });
}
