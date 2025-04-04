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

  group('StringConvert::extractEmailAddress::', () {
    group('Basic Functionality', () {
      test('should not extract strings separated by spaces', () {
        const input = 'user1@example.com user2@example.com';
        final expected = ['user1@example.com', 'user2@example.com'];
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });

      test('should extract strings separated by commas', () {
        const input = 'user1@example.com,user2@example.com';
        final expected = ['user1@example.com', 'user2@example.com'];
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });

      test('should extract strings separated by semicolons', () {
        const input = 'user1@example.com;user2@example.com';
        final expected = ['user1@example.com', 'user2@example.com'];
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });

      test('should extract strings separated by mixed separators', () {
        const input = 'user1@example.com, user2@example.com; user3@example.com';
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });

      test('should handle multiple consecutive separators', () {
        const input =
            'user1@example.com,,;  user2@example.com;;  user3@example.com';
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });
    });

    group('Edge Cases', () {
      test('should handle empty input', () {
        const input = '';
        final expected = <String>[];
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });

      test('should handle input with only separators', () {
        const input = ',, ;;   ';
        final expected = <String>[];
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });

      test('should handle trailing and leading separators', () {
        const input = ', user1@example.com; user2@example.com ,';
        final expected = ['user1@example.com', 'user2@example.com'];
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });

      test('should handle extra spaces between separators', () {
        const input = 'user1@example.com   ,   user2@example.com ;   user3@example.com';
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });
    });

    group('Stress Tests', () {
      test('should handle a large number of strings', () {
        final input = List.generate(
          1000,
          (index) =>
              'user$index@example.com${index % 3 == 0 ? ',' : ';'}',
        ).join();
        final expected =
            List.generate(1000, (index) => 'user$index@example.com');
        expect(StringConvert.extractEmailAddress(input), equals(expected));
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
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });

      test('should handle Base64 encoded input', () {
        String input = 'dXNlcjFAZXhhbXBsZS5jb20gdXNlcjJAZXhhbXBsZS5jb20gdXNlcjNAZXhhbXBsZS5jb20=';
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });

      test('should handle input with both URL encoding and Base64 encoding', () {
        String input = Uri.encodeComponent(base64.encode(utf8.encode('user1@example.com user2@example.com user3@example.com')));
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });
    });

    group('Failing Cases', () {
      test('should return empty list for empty input', () {
        String input = '';
        expect(StringConvert.extractEmailAddress(input), equals([]));
      });

      test('should return empty list if input is only separators', () {
        String input = ' , ; ';
        expect(StringConvert.extractEmailAddress(input), equals([]));
      });

      test('should return correct result for input with invalid separators', () {
        String input = 'user1@example.com,,user2@example.com;;;user3@example.com';
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });

      test('should return empty list for input with only whitespace and separators', () {
        String input = '   , ;  \n';
        expect(StringConvert.extractEmailAddress(input), equals([]));
      });

      test('should handle input with newline characters', () {
        // Arrange
        String input = 'user1@example.com\nuser2@example.com;user3@example.com';
        final expected = [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com'
        ];
        expect(StringConvert.extractEmailAddress(input), equals(expected));
      });
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

  group('StringConvert::getMediaTypeFromBase64ImageTag::', () {
    test('should return correct MediaType for valid JPEG base64 tag', () {
      const validJpegTag = 'data:image/jpeg;base64,/9j/4AAQSkZJRg==';
      final result = StringConvert.getMediaTypeFromBase64ImageTag(validJpegTag);
      expect(result, isNotNull);
      expect(result!.type, 'image');
      expect(result.subtype, 'jpeg');
    });

    test('should return correct MediaType for valid PNG base64 tag', () {
      const validPngTag = 'data:image/png;base64,iVBORw0KGgo===';
      final result = StringConvert.getMediaTypeFromBase64ImageTag(validPngTag);
      expect(result, isNotNull);
      expect(result!.type, 'image');
      expect(result.subtype, 'png');
    });

    test('should return null for string not starting with "data:"', () {
      const invalidTag = 'image/jpeg;base64,/9j/4AAQSkZJRg==';
      final result = StringConvert.getMediaTypeFromBase64ImageTag(invalidTag);
      expect(result, isNull);
    });

    test('should return null for string without ";base64,"', () {
      const invalidTag = 'data:image/jpeg,/9j/4AAQSkZJRg==';
      final result = StringConvert.getMediaTypeFromBase64ImageTag(invalidTag);
      expect(result, isNull);
    });

    test('should return null for invalid format', () {
      const invalidTag = 'data:invalid;base64,data';
      final result = StringConvert.getMediaTypeFromBase64ImageTag(invalidTag);
      expect(result, isNull);
    });

    test('should return null for empty string', () {
      const emptyTag = '';
      final result = StringConvert.getMediaTypeFromBase64ImageTag(emptyTag);
      expect(result, isNull);
    });

    test('should handle null input gracefully', () {
      const String? nullTag = null;
      expect(() => StringConvert.getMediaTypeFromBase64ImageTag(nullTag!), throwsA(isA<TypeError>()));
    });
  });

  group('StringConvert::isTextTable::', () {
    // ---------------------------
    // Test cases cho Markdown tables
    // ---------------------------
    test('should return true for standard Markdown table', () {
      const table = """
        | Header 1 | Header 2 |
        |----------|----------|
        | Cell 1   | Cell 2   |
      """;
      expect(StringConvert.isTextTable(table), isTrue);
    });

    test('should return true for Markdown table with alignment', () {
      const table = """
| Left | Center | Right |
|:-----|:------:|------:|
| 1    | 2      | 3     |
""";
      expect(StringConvert.isTextTable(table), isTrue);
    });

    test('should return true for Markdown table without outer pipes', () {
      const table = """
        Header 1 | Header 2
        ---------|---------
        Cell 1   | Cell 2
      """;
      expect(StringConvert.isTextTable(table), isTrue);
    });

    test('should return true for multi-line Markdown table', () {
      const table = """
        | Column 1 | Column 2 |
        |----------|----------|
        | Line 1   | Data 1   |
        | Line 2   | Data 2   |
        | Line 3   | Data 3   |
      """;
      expect(StringConvert.isTextTable(table), isTrue);
    });

    // ---------------------------
    // Test cases cho ASCII art tables
    // ---------------------------
    test('should return true for basic ASCII art table', () {
      const table = """
        +--------+--------+
        | Cell 1 | Cell 2 |
        +--------+--------+
        | Data 1 | Data 2 |
        +--------+--------+
      """;
      expect(StringConvert.isTextTable(table), isTrue);
    });

    test('should return true for complex ASCII art table', () {
      const table = """
        ---------++-----------------++-----------------|
                 ||      Global     ||  Working hours  |
        Requests ||-----------------++-----------------|
                 ||   LB   | Proxy  ||   LB   | Proxy  |
        ---------++--------|--------++--------+--------|
           50%   ||  0.04s |  0.07s ||  0.04s |  3.26s |
        ---------++--------|--------++--------+--------|
      """;
      expect(StringConvert.isTextTable(table), isTrue);
    });

    test('should return true for ASCII table with mixed borders', () {
      const table = """
        /===========\\===========/
        |  Column 1 |  Column 2 |
        \\===========/===========/
        |   Data 1  |   Data 2  |
        /===========\\===========/
      """;
      expect(StringConvert.isTextTable(table), isTrue);
    });

    // ---------------------------
    // Test cases cho invalid tables
    // ---------------------------
    test('should return false for plain text', () {
      const text = 'This is not a table at all';
      expect(StringConvert.isTextTable(text), isFalse);
    });

    test('should return false for single pipe character', () {
      const text = '|';
      expect(StringConvert.isTextTable(text), isFalse);
    });

    test('should return false for text with random pipes', () {
      const text = 'This | is | not | a | table';
      expect(StringConvert.isTextTable(text), isFalse);
    });

    test('should return false for empty string', () {
      expect(StringConvert.isTextTable(''), isFalse);
    });

    test('should return false for whitespace-only string', () {
      expect(StringConvert.isTextTable('   \n   \n   '), isFalse);
    });

    test('should return true for separator-only Markdown', () {
      const text = """
        |----------|----------|
        |----------|----------|
      """;
      expect(StringConvert.isTextTable(text), isTrue);
    });

    test('should return false for single-line Markdown', () {
      const text = '| Header 1 | Header 2 |';
      expect(StringConvert.isTextTable(text), isFalse);
    });

    test('should return false for malformed ASCII art', () {
      const text = """
        +--------+--------+
         Just some text
        +--------+--------+
      """;
      expect(StringConvert.isTextTable(text), isFalse);
    });

    // ---------------------------
    // Edge cases
    // ---------------------------
    test('should handle very wide tables', () {
      final table = """
        | ${'a' * 100} | ${'b' * 100} |
        | ${'-' * 100} | ${'-' * 100} |
        | ${'c' * 100} | ${'d' * 100} |
      """;
      expect(StringConvert.isTextTable(table), isTrue);
    });

    test('should handle tables with many columns', () {
      const table = """
        | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
        |---|---|---|---|---|---|---|---|---|----|
        | a | b | c | d | e | f | g | h | i | j  |
      """;
      expect(StringConvert.isTextTable(table), isTrue);
    });

    test('should handle tables with empty cells', () {
      const table = """
        | Header 1 | Header 2 |
        |----------|----------|
        |          | Cell 2   |
        | Cell 1   |          |
      """;
      expect(StringConvert.isTextTable(table), isTrue);
    });

    test('should handle tables with special characters', () {
      const table = """
        |  \$  |  %  |  &  |
        |-----|-----|-----|
        |  #  |  @  |  !  |
      """;
      expect(StringConvert.isTextTable(table), isTrue);
    });

    test('should handle tables with only horizontal borders', () {
      const table = """
        -----------------
           Data  |  Data  
        -----------------
      """;
      expect(StringConvert.isTextTable(table), isTrue);
    });

    test('should return true for text with only borders', () {
      const text = """
        +-----+-----+
        +-----+-----+
      """;
      expect(StringConvert.isTextTable(text), isTrue);
    });
  });
}
