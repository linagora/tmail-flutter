import 'dart:convert';

import 'package:core/utils/string_convert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringConvert::extractStrings::', () {
    group('Basic Functionality', () {
      test('should extract strings separated by spaces', () {
        const input = 'user1@example.com user2@example.com';
        final expected = ['user1@example.com', 'user2@example.com'];
        expect(StringConvert.extractStrings(input), equals(expected));
      });

      test('should extract strings separated by commas', () {
        const input = 'user1@example.com,user2@example.com';
        final expected = ['user1@example.com', 'user2@example.com'];
        expect(StringConvert.extractStrings(input), equals(expected));
      });

      test('should extract strings separated by semicolons', () {
        const input = 'user1@example.com;user2@example.com';
        final expected = ['user1@example.com', 'user2@example.com'];
        expect(StringConvert.extractStrings(input), equals(expected));
      });

      test('should extract strings separated by mixed separators', () {
        const input = 'user1@example.com, user2@example.com; user3@example.com';
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractStrings(input), equals(expected));
      });

      test('should handle multiple consecutive separators', () {
        const input =
            'user1@example.com,,;  user2@example.com;;  user3@example.com';
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractStrings(input), equals(expected));
      });
    });

    group('Edge Cases', () {
      test('should handle empty input', () {
        const input = '';
        final expected = <String>[];
        expect(StringConvert.extractStrings(input), equals(expected));
      });

      test('should handle input with only separators', () {
        const input = ',, ;;   ';
        final expected = <String>[];
        expect(StringConvert.extractStrings(input), equals(expected));
      });

      test('should handle trailing and leading separators', () {
        const input = ', user1@example.com; user2@example.com ,';
        final expected = ['user1@example.com', 'user2@example.com'];
        expect(StringConvert.extractStrings(input), equals(expected));
      });

      test('should handle extra spaces between separators', () {
        const input = 'user1@example.com   ,   user2@example.com ;   user3@example.com';
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractStrings(input), equals(expected));
      });
    });

    group('Stress Tests', () {
      test('should handle a large number of strings', () {
        final input = List.generate(
          1000,
          (index) =>
              'user$index@example.com${index % 3 == 0 ? ',' : index % 3 == 1 ? ';' : ' '}',
        ).join();
        final expected =
            List.generate(1000, (index) => 'user$index@example.com');
        expect(StringConvert.extractStrings(input), equals(expected));
      });
    });

    group('Encoded Input Tests', () {
      test('should handle URL encoded input', () {
        String input = 'user1%40example.com%20user2%40example.com%20user3%40example.com';
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractStrings(input), equals(expected));
      });

      test('should handle Base64 encoded input', () {
        String input = 'dXNlcjFAZXhhbXBsZS5jb20gdXNlcjJAZXhhbXBsZS5jb20gdXNlcjNAZXhhbXBsZS5jb20=';
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractStrings(input), equals(expected));
      });

      test('should handle input with both URL encoding and Base64 encoding', () {
        String input = Uri.encodeComponent(base64.encode(utf8.encode('user1@example.com user2@example.com user3@example.com')));
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractStrings(input), equals(expected));
      });
    });

    group('Failing Cases', () {
      test('should return empty list for empty input', () {
        String input = '';
        expect(StringConvert.extractStrings(input), equals([]));
      });

      test('should return empty list if input is only separators', () {
        String input = ' , ; ';
        expect(StringConvert.extractStrings(input), equals([]));
      });

      test('should return correct result for input with invalid separators', () {
        String input = 'user1@example.com,,user2@example.com;;;user3@example.com';
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractStrings(input), equals(expected));
      });

      test('should return empty list for input with only whitespace and separators', () {
        String input = '   , ;  \n';
        expect(StringConvert.extractStrings(input), equals([]));
      });

      test('should handle input with newline characters', () {
        // Arrange
        String input = 'user1@example.com\nuser2@example.com;user3@example.com';
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractStrings(input), equals(expected));
      });
    });
  });
}
