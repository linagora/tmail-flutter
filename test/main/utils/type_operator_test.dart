import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';

bool isNotBadCredentialsExceptionUseIsNotOperator(dynamic exception) {
  return exception is! BadCredentialsException;
}

bool isBadCredentialsExceptionUseIsOperator(dynamic exception) {
  return exception is BadCredentialsException;
}

bool isBadCredentialsExceptionUseNotIsOperator(dynamic exception) {
  return exception !is BadCredentialsException;
}

void main() {
  group('is! operator unit test', () {
    test('should return true when exception is not a BadCredentialsException', () {
      // Arrange
      const connectionError = ConnectionError();

      // Act
      final result = isNotBadCredentialsExceptionUseIsNotOperator(connectionError);

      // Assert
      expect(result, true);
    });

    test('should return false when exception is a BadCredentialsException', () {
      // Arrange
      const badCredentialsException = BadCredentialsException();

      // Act
      final result = isNotBadCredentialsExceptionUseIsNotOperator(badCredentialsException);

      // Assert
      expect(result, false);
    });
  });

  group('is operator unit test', () {
    test('should return true when exception is a BadCredentialsException', () {
      // Arrange
      const badCredentialsException = BadCredentialsException();

      // Act
      final result = isBadCredentialsExceptionUseIsOperator(badCredentialsException);

      // Assert
      expect(result, true);
    });

    test('should return false when exception is not a BadCredentialsException', () {
      // Arrange
      const connectionError = ConnectionError();

      // Act
      final result = isBadCredentialsExceptionUseIsOperator(connectionError);

      // Assert
      expect(result, false);
    });
  });

  group('!is operator unit test', () {
    test('should return true when exception is a BadCredentialsException', () {
      // Arrange
      const badCredentialsException = BadCredentialsException();

      // Act
      final result = isBadCredentialsExceptionUseNotIsOperator(badCredentialsException);

      // Assert
      expect(result, true);
    });

    test('should return false when exception is not a BadCredentialsException', () {
      // Arrange
      const connectionError = ConnectionError();

      // Act
      final result = isBadCredentialsExceptionUseNotIsOperator(connectionError);

      // Assert
      expect(result, false);
    });
  });
}
