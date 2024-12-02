import 'package:core/utils/string_convert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringConvert::decodeBase64ToString::test', () {
    test('should decode a valid Base64 string to a normal string', () {
      // Arrange
      const base64Encoded = 'SGVsbG8gV29ybGQh';
      const expectedDecoded = 'Hello World!';

      // Act
      final result = StringConvert.decodeBase64ToString(base64Encoded);

      // Assert
      expect(result, expectedDecoded);
    });

    test('should return the original string for invalid Base64 input', () {
      // Arrange
      const invalidBase64 = 'InvalidBase64@@';

      // Act
      final result = StringConvert.decodeBase64ToString(invalidBase64);

      // Assert
      expect(result, invalidBase64);
    });

    test('should return the original string for empty input', () {
      // Arrange
      const emptyInput = '';

      // Act
      final result = StringConvert.decodeBase64ToString(emptyInput);

      // Assert
      expect(result, emptyInput);
    });
  });
}