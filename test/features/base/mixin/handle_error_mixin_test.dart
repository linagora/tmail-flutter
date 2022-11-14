import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/error_type_handler/set_method_error_handler_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';

class TestSetErrorHandler with HandleSetErrorMixin {}

void main() {
  late TestSetErrorHandler testHandler;

  setUp(() {
    testHandler = TestSetErrorHandler();
  });


  group('Handle Not Destroyed Error', () {
    test('should not invoke notDestroyedHandler when notDestroyedError null but notDestroyedHandlers non-null', () {
      var counterWillNotBeChange = 0;

      bool notDestroyedHandler(MapEntry<Id, SetError> setError) {
        counterWillNotBeChange++;
        return false;
      }

      testHandler.handleSetErrors(
        notDestroyedError: null,
        notDestroyedHandlers: {notDestroyedHandler}
      );

      expect(counterWillNotBeChange, equals(0));
    });
    test('should invoke unCatchErrorHandler when notDestroyedError null but notDestroyedHandlers null', () {
      SetMethodErrors? notDestroyedError = {
        Id("c1"): SetError(SetError.notFound),
      };

      var counterWillBeEqualOne = 0;

      bool unCatchErrorHandler(MapEntry<Id, SetError> setError) {
        counterWillBeEqualOne++;
        return false;
      }

      testHandler.handleSetErrors(
        notDestroyedError: notDestroyedError,
        notDestroyedHandlers: null,
        unCatchErrorHandler: unCatchErrorHandler
      );

      expect(counterWillBeEqualOne, equals(1));
    });
    test('should handle error successfully when notDestroyedHandlers non-null and one of them handle notDestroyedError', () {
      SetMethodErrors? notDestroyedError = {
        Id("c1"): SetError(SetError.notFound),
      };
      var counterWillBeIncreaseWhenHandleSucceeded = 0;

      bool notDestroyedHandler1(MapEntry<Id, SetError> setError) {
        return false;
      }

      bool notDestroyedHandler2(MapEntry<Id, SetError> setError) {
        if (setError.value.type == SetError.notFound) {
          counterWillBeIncreaseWhenHandleSucceeded++;
          return true;
        }
        return false;
      }

      bool unCatchErrorHandler(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenHandleSucceeded++;
        return false;
      }

      testHandler.handleSetErrors(
          notDestroyedError: notDestroyedError,
          notDestroyedHandlers: {notDestroyedHandler1, notDestroyedHandler2},
          unCatchErrorHandler: unCatchErrorHandler
      );

      expect(counterWillBeIncreaseWhenHandleSucceeded, equals(1));
    });
    test('should stop handler error when notDestroyedHandlers non-null and one of them handle notDestroyedError successfully', () {
      SetMethodErrors? notDestroyedError = {
        Id("c1"): SetError(SetError.notFound),
      };
      var counterWillBeIncreaseWhenInvokeHandler = 0;

      bool notDestroyedHandler1(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool notDestroyedHandler2(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        if (setError.value.type == SetError.notFound) {
          return true;
        }
        return false;
      }

      bool notDestroyedHandler3(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool unCatchErrorHandler(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      testHandler.handleSetErrors(
          notDestroyedError: notDestroyedError,
          notDestroyedHandlers: {notDestroyedHandler1, notDestroyedHandler2, notDestroyedHandler3},
          unCatchErrorHandler: unCatchErrorHandler
      );

      expect(counterWillBeIncreaseWhenInvokeHandler, equals(2));
    });
    test('should call unCatchErrorHandler when notDestroyedHandlers non-null and no-one can handle notDestroyedError', () {
      SetMethodErrors? notDestroyedError = {
        Id("c1"): SetError(SetError.notFound),
      };
      var counterWillBeIncreaseWhenInvokeHandler = 0;

      bool notDestroyedHandler1(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool notDestroyedHandler2(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool unCatchErrorHandler(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      testHandler.handleSetErrors(
          notDestroyedError: notDestroyedError,
          notDestroyedHandlers: {notDestroyedHandler1, notDestroyedHandler2},
          unCatchErrorHandler: unCatchErrorHandler
      );

      expect(counterWillBeIncreaseWhenInvokeHandler, equals(3));
    });
    test('should invoke both unCatchErrorHandler and handler when have some kinds of error were handle successfully', () {
      SetMethodErrors? notDestroyedError = {
        Id("c1"): SetError(SetError.notFound),
        Id("c2"): SetError(SetError.forbidden),
      };
      var counterWillBeIncreaseWhenInvokeHandler = 0;
      var counterWillBeIncreaseWhenInvokeUnCatchHandler = 0;

      bool notDestroyedHandler1(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool notDestroyedHandler2(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        if (setError.value.type == SetError.notFound) {
          return true;
        }
        return false;
      }

      bool notDestroyedHandler3(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool unCatchErrorHandler(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeUnCatchHandler++;
        return false;
      }

      testHandler.handleSetErrors(
          notDestroyedError: notDestroyedError,
          notDestroyedHandlers: {notDestroyedHandler1, notDestroyedHandler2, notDestroyedHandler3},
          unCatchErrorHandler: unCatchErrorHandler
      );

      expect(counterWillBeIncreaseWhenInvokeHandler, equals(5));
      expect(counterWillBeIncreaseWhenInvokeUnCatchHandler, equals(1));
    });
  });

  group('Handle Not Updated Error', () {
    test('should not invoke notUpdatedHandlers when notUpdatedError null but notUpdatedHandlers non-null', () {
      var counterWillNotBeChange = 0;

      bool notUpdateHandler(MapEntry<Id, SetError> setError) {
        counterWillNotBeChange++;
        return false;
      }

      testHandler.handleSetErrors(
          notUpdatedError: null,
          notUpdatedHandlers: {notUpdateHandler}
      );

      expect(counterWillNotBeChange, equals(0));
    });
    test('should invoke unCatchErrorHandler when notUpdatedError null but notUpdatedHandlers null', () {
      SetMethodErrors? notUpdatedError = {
        Id("c1"): SetError(SetError.notFound),
      };

      var counterWillBeEqualOne = 0;

      bool unCatchErrorHandler(MapEntry<Id, SetError> setError) {
        counterWillBeEqualOne++;
        return false;
      }

      testHandler.handleSetErrors(
          notUpdatedError: notUpdatedError,
          notUpdatedHandlers: null,
          unCatchErrorHandler: unCatchErrorHandler
      );

      expect(counterWillBeEqualOne, equals(1));
    });
    test('should handle error successfully when notUpdatedHandlers non-null and one of them handle notUpdatedError', () {
      SetMethodErrors? notUpdatedError = {
        Id("c1"): SetError(SetError.notFound),
      };
      var counterWillBeIncreaseWhenInvokeHandler = 0;

      bool notUpdatedHandler1(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool notUpdatedHandler2(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        if (setError.value.type == SetError.notFound) {
          return true;
        }
        return false;
      }

      bool unCatchErrorHandler(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      testHandler.handleSetErrors(
          notUpdatedError: notUpdatedError,
          notUpdatedHandlers: {notUpdatedHandler1, notUpdatedHandler2},
          unCatchErrorHandler: unCatchErrorHandler
      );

      expect(counterWillBeIncreaseWhenInvokeHandler, equals(2));
    });
    test('should stop handler error when notUpdatedHandlers non-null and one of them handle notUpdatedError successfully', () {
      SetMethodErrors? notUpdatedError = {
        Id("c1"): SetError(SetError.notFound),
      };
      var counterWillBeIncreaseWhenInvokeHandler = 0;

      bool notUpdatedHandler1(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool notUpdatedHandler2(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        if (setError.value.type == SetError.notFound) {
          return true;
        }
        return false;
      }

      bool notUpdatedHandler3(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool unCatchErrorHandler(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      testHandler.handleSetErrors(
          notUpdatedError: notUpdatedError,
          notUpdatedHandlers: {notUpdatedHandler1, notUpdatedHandler2, notUpdatedHandler3},
          unCatchErrorHandler: unCatchErrorHandler
      );

      expect(counterWillBeIncreaseWhenInvokeHandler, equals(2));
    });
    test('should call unCatchErrorHandler when notUpdatedHandlers non-null and no-one can handle notUpdatedError', () {
      SetMethodErrors? notUpdatedError = {
        Id("c1"): SetError(SetError.notFound),
      };
      var counterWillBeIncreaseWhenInvokeHandler = 0;

      bool notUpdatedHandler1(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool notUpdatedHandler2(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool unCatchErrorHandler(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      testHandler.handleSetErrors(
          notUpdatedError: notUpdatedError,
          notUpdatedHandlers: {notUpdatedHandler1, notUpdatedHandler2},
          unCatchErrorHandler: unCatchErrorHandler
      );

      expect(counterWillBeIncreaseWhenInvokeHandler, equals(3));
    });
  });

  group('Handle Not Created Error', () {
    test('should not invoke notCreatedHandlers when notCreatedError null but notCreatedHandlers non-null', () {
      var counterWillNotBeChange = 0;

      bool notCreatedHandler(MapEntry<Id, SetError> setError) {
        counterWillNotBeChange++;
        return false;
      }

      testHandler.handleSetErrors(
          notCreatedError: null,
          notCreatedHandlers: {notCreatedHandler}
      );

      expect(counterWillNotBeChange, equals(0));
    });
    test('should invoke unCatchErrorHandler when notCreatedError null but notCreatedHandlers null', () {
      SetMethodErrors? notCreatedError = {
        Id("c1"): SetError(SetError.notFound),
      };

      var counterWillBeEqualOne = 0;

      bool unCatchErrorHandler(MapEntry<Id, SetError> setError) {
        counterWillBeEqualOne++;
        return false;
      }

      testHandler.handleSetErrors(
          notCreatedError: notCreatedError,
          notCreatedHandlers: null,
          unCatchErrorHandler: unCatchErrorHandler
      );

      expect(counterWillBeEqualOne, equals(1));
    });
    test('should handle error successfully when notCreatedHandlers non-null and one of them handle notCreatedError', () {
      SetMethodErrors? notCreatedError = {
        Id("c1"): SetError(SetError.notFound),
      };
      var counterWillBeIncreaseWhenInvokeHandler = 0;

      bool notCreatedHandler1(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool notCreatedHandler2(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        if (setError.value.type == SetError.notFound) {
          return true;
        }
        return false;
      }

      bool unCatchErrorHandler(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      testHandler.handleSetErrors(
          notCreatedError: notCreatedError,
          notCreatedHandlers: {notCreatedHandler1, notCreatedHandler2},
          unCatchErrorHandler: unCatchErrorHandler
      );

      expect(counterWillBeIncreaseWhenInvokeHandler, equals(2));
    });
    test('should stop handler error when notCreatedHandlers non-null and one of them handle notCreatedError successfully', () {
      SetMethodErrors? notCreatedError = {
        Id("c1"): SetError(SetError.notFound),
      };
      var counterWillBeIncreaseWhenInvokeHandler = 0;

      bool notCreatedHandler1(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool notCreatedHandler2(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        if (setError.value.type == SetError.notFound) {
          return true;
        }
        return false;
      }

      bool notCreatedHandler3(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool unCatchErrorHandler(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      testHandler.handleSetErrors(
          notCreatedError: notCreatedError,
          notCreatedHandlers: {notCreatedHandler1, notCreatedHandler2, notCreatedHandler3},
          unCatchErrorHandler: unCatchErrorHandler
      );

      expect(counterWillBeIncreaseWhenInvokeHandler, equals(2));
    });
    test('should call unCatchErrorHandler when notCreatedHandlers non-null and no-one can handle notCreatedError', () {
      SetMethodErrors? notCreatedError = {
        Id("c1"): SetError(SetError.notFound),
      };
      var counterWillBeIncreaseWhenInvokeHandler = 0;

      bool notCreatedHandler1(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool notCreatedHandler2(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      bool unCatchErrorHandler(MapEntry<Id, SetError> setError) {
        counterWillBeIncreaseWhenInvokeHandler++;
        return false;
      }

      testHandler.handleSetErrors(
          notCreatedError: notCreatedError,
          notCreatedHandlers: {notCreatedHandler1, notCreatedHandler2},
          unCatchErrorHandler: unCatchErrorHandler
      );

      expect(counterWillBeIncreaseWhenInvokeHandler, equals(3));
    });
  });
}