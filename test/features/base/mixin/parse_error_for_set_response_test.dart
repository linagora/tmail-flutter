import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:labels/method/set/set_label_response.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';

class TestSetErrorHandler with HandleSetErrorMixin {}

void main() {
  late TestSetErrorHandler testHandler;

  setUp(() {
    testHandler = TestSetErrorHandler();
  });

  group('HandleSetErrorMixin::parseErrorForSetResponse', () {
    final requestId = Id('request-123');
    final accountId = AccountId(Id('account-1'));

    test('should throw InvalidArgumentsMethodResponse when error type is invalidArguments in notCreated', () {
      // Arrange
      final setError = SetError(ErrorMethodResponse.invalidArguments);
      final response = SetLabelResponse(
        accountId,
        notCreated: {requestId: setError},
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(isA<InvalidArgumentsMethodResponse>()),
      );
    });

    test('should throw InvalidArgumentsMethodResponse with description when provided', () {
      // Arrange
      final setError = SetError(
        ErrorMethodResponse.invalidArguments,
        description: 'Label name cannot be empty',
      );
      final response = SetLabelResponse(
        accountId,
        notCreated: {requestId: setError},
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(
          isA<InvalidArgumentsMethodResponse>().having(
            (e) => e.description,
            'description',
            'Label name cannot be empty',
          ),
        ),
      );
    });

    test('should throw InvalidArgumentsMethodResponse when error type is invalidArguments in notUpdated', () {
      // Arrange
      final setError = SetError(ErrorMethodResponse.invalidArguments);
      final response = SetLabelResponse(
        accountId,
        notUpdated: {requestId: setError},
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(isA<InvalidArgumentsMethodResponse>()),
      );
    });

    test('should throw InvalidArgumentsMethodResponse when error type is invalidArguments in notDestroyed', () {
      // Arrange
      final setError = SetError(ErrorMethodResponse.invalidArguments);
      final response = SetLabelResponse(
        accountId,
        notDestroyed: {requestId: setError},
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(isA<InvalidArgumentsMethodResponse>()),
      );
    });

    test('should throw InvalidResultReferenceMethodResponse when error type is invalidResultReference', () {
      // Arrange
      final setError = SetError(ErrorMethodResponse.invalidResultReference);
      final response = SetLabelResponse(
        accountId,
        notCreated: {requestId: setError},
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(isA<InvalidResultReferenceMethodResponse>()),
      );
    });

    test('should throw InvalidResultReferenceMethodResponse with description when provided', () {
      // Arrange
      final setError = SetError(
        ErrorMethodResponse.invalidResultReference,
        description: 'Invalid reference to previous result',
      );
      final response = SetLabelResponse(
        accountId,
        notCreated: {requestId: setError},
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(
          isA<InvalidResultReferenceMethodResponse>().having(
            (e) => e.description,
            'description',
            'Invalid reference to previous result',
          ),
        ),
      );
    });

    test('should throw UnknownMethodResponse when error type is not recognized', () {
      // Arrange
      final setError = SetError(ErrorMethodResponse.serverFail);
      final response = SetLabelResponse(
        accountId,
        notCreated: {requestId: setError},
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(isA<UnknownMethodResponse>()),
      );
    });

    test('should throw UnknownMethodResponse with description when error type is unknown', () {
      // Arrange
      final setError = SetError(
        ErrorMethodResponse.serverFail,
        description: 'Internal server error',
      );
      final response = SetLabelResponse(
        accountId,
        notCreated: {requestId: setError},
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(
          isA<UnknownMethodResponse>().having(
            (e) => e.description,
            'description',
            'Internal server error',
          ),
        ),
      );
    });

    test('should throw UnknownMethodResponse when requestId is not found in error map', () {
      // Arrange
      final differentId = Id('different-request');
      final setError = SetError(ErrorMethodResponse.invalidArguments);
      final response = SetLabelResponse(
        accountId,
        notCreated: {differentId: setError},
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(isA<UnknownMethodResponse>()),
      );
    });

    test('should throw UnknownMethodResponse without description when requestId not found', () {
      // Arrange
      final response = SetLabelResponse(accountId);

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(
          isA<UnknownMethodResponse>().having(
            (e) => e.description,
            'description',
            isNull,
          ),
        ),
      );
    });

    test('should check all error maps (notCreated, notUpdated, notDestroyed)', () {
      // Arrange - error in notUpdated
      final setError = SetError(ErrorMethodResponse.invalidArguments);
      final response = SetLabelResponse(
        accountId,
        notUpdated: {requestId: setError},
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(isA<InvalidArgumentsMethodResponse>()),
      );
    });

    test('should handle response with multiple errors and find the correct one', () {
      // Arrange
      final targetError = SetError(
        ErrorMethodResponse.invalidArguments,
        description: 'Target error',
      );
      final otherError = SetError(
        ErrorMethodResponse.serverFail,
        description: 'Other error',
      );
      final response = SetLabelResponse(
        accountId,
        notCreated: {
          Id('other-1'): otherError,
          requestId: targetError,
          Id('other-2'): otherError,
        },
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(
          isA<InvalidArgumentsMethodResponse>().having(
            (e) => e.description,
            'description',
            'Target error',
          ),
        ),
      );
    });

    test('should handle null SetResponse', () {
      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(null, requestId),
        throwsA(isA<UnknownMethodResponse>()),
      );
    });

    test('should handle SetError with notFound type', () {
      // Arrange
      final setError = SetError(SetError.notFound);
      final response = SetLabelResponse(
        accountId,
        notCreated: {requestId: setError},
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(isA<UnknownMethodResponse>()),
      );
    });

    test('should handle SetError with forbidden type', () {
      // Arrange
      final setError = SetError(SetError.forbidden);
      final response = SetLabelResponse(
        accountId,
        notCreated: {requestId: setError},
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(isA<UnknownMethodResponse>()),
      );
    });

    test('should handle response when error in notDestroyed only', () {
      // Arrange
      final setError = SetError(ErrorMethodResponse.invalidArguments);
      final response = SetLabelResponse(
        accountId,
        notDestroyed: {requestId: setError},
      );

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(isA<InvalidArgumentsMethodResponse>()),
      );
    });

    test('should handle empty response correctly', () {
      // Arrange
      final response = SetLabelResponse(accountId);

      // Act & Assert
      expect(
        () => testHandler.parseErrorForSetResponse(response, requestId),
        throwsA(isA<UnknownMethodResponse>()),
      );
    });

    test('should preserve error descriptions correctly', () {
      // Arrange
      const testDescription = 'Duplicate label name exists';
      final setError = SetError(
        ErrorMethodResponse.invalidArguments,
        description: testDescription,
      );
      final response = SetLabelResponse(
        accountId,
        notCreated: {requestId: setError},
      );

      // Act
      try {
        testHandler.parseErrorForSetResponse(response, requestId);
        fail('Should have thrown exception');
      } catch (e) {
        // Assert
        expect(e, isA<InvalidArgumentsMethodResponse>());
        expect((e as InvalidArgumentsMethodResponse).description, testDescription);
      }
    });
  });
}
