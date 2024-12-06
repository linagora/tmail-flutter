import 'dart:convert';

import 'package:core/domain/exceptions/string_exception.dart';
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

  group('string convert test:', () {
    const testText = 'Hello';
    test(
      'should use utf8 decoder '
      'when isHtml is true',
    () {
      // arrange
      final bytes = utf8.encode(testText);
      
      // act
      final result = StringConvert.decodeFromBytes(bytes, charset: null, isHtml: true);
      
      // assert
      expect(result, testText);
    });

    test(
      'should use utf8 decoder '
      'when charset contains utf-8',
    () {
      // arrange
      final bytes = utf8.encode(testText);
      
      // act
      final result = StringConvert.decodeFromBytes(bytes, charset: 'utf-8');
      
      // assert
      expect(result, testText);
    });

    test(
      'should use latin1 decoder '
      'when charset contains latin-1',
    () {
      // arrange
      final bytes = latin1.encode(testText);
      
      // act
      final result = StringConvert.decodeFromBytes(bytes, charset: 'latin-1');
      
      // assert
      expect(result, testText);
    });

    test(
      'should use ascii decoder '
      'when charset contains ascii',
    () {
      // arrange
      final bytes = ascii.encode(testText);
      
      // act
      final result = StringConvert.decodeFromBytes(bytes, charset: 'ascii');
      
      // assert
      expect(result, testText);
    });

    test(
      'should throw NullCharsetException '
      'when charset is null',
    () {
      // arrange
      final bytes = utf8.encode(testText);
      
      // assert
      expect(
        () => StringConvert.decodeFromBytes(bytes, charset: null),
        throwsA(isA<NullCharsetException>()),
      );
    });

    test(
      'should throw UnsupportedCharsetException '
      'when charset is unsupported',
    () {
      // arrange
      final bytes = utf8.encode(testText);
      
      // assert
      expect(
        () => StringConvert.decodeFromBytes(bytes, charset: 'unsupported'),
        throwsA(isA<UnsupportedCharsetException>()),
      );
    });
  });
}