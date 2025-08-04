import 'dart:convert';

import 'package:core/domain/exceptions/string_exception.dart';
import 'package:core/utils/mail/named_address.dart';
import 'package:core/utils/string_convert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringConvert.decodeBase64ToString', () {
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

  group('StringConvert.extractEmailAddress', () {
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

  group('StringConvert.decodeFromBytes', () {
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

  group('StringConvert.getMediaTypeFromBase64ImageTag', () {
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

  group('StringConvert.isTextTable', () {
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

    test('should return true for separator-only Markdown', () {
      const text = """
        |----------|----------|
        |----------|----------|
      """;
      expect(StringConvert.isTextTable(text), isTrue);
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

  group('StringConvert.extractNamedAddresses', () {
    test('Extracts plain emails', () {
      const input = 'user1@example.com, user2@example.com; user3@example.com';
      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: '', address: 'user1@example.com'),
          NamedAddress(name: '', address: 'user2@example.com'),
          NamedAddress(name: '', address: 'user3@example.com'),
        ]),
      );
    });

    test('Extracts quoted name and email', () {
      const input = '"John Doe" <john@example.com>, "Jane" <jane@example.com>';
      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: 'John Doe', address: 'john@example.com'),
          NamedAddress(name: 'Jane', address: 'jane@example.com'),
        ]),
      );
    });

    test('Extracts mixed quoted and plain emails', () {
      const input =
          '"Alex" <alex@example.com>, user@example.com, "Sara" <sara@example.com>';
      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: 'Alex', address: 'alex@example.com'),
          NamedAddress(name: '', address: 'user@example.com'),
          NamedAddress(name: 'Sara', address: 'sara@example.com'),
        ]),
      );
    });

    test('Handles URL-encoded input', () {
      const input =
          'user1%40example.com%2C%20%22User%202%22%20%3Cuser2%40example.com%3E';
      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: '', address: 'user1@example.com'),
          NamedAddress(name: 'User 2', address: 'user2@example.com'),
        ]),
      );
    });

    test('Handles base64 encoded input', () {
      const raw =
          'user1@example.com user2@example.com "Name Three" <user3@example.com>';
      final encoded = base64.encode(utf8.encode(raw));

      final result = StringConvert.extractNamedAddresses(encoded);

      expect(
        result,
        equals([
          NamedAddress(name: '', address: 'user1@example.com'),
          NamedAddress(name: '', address: 'user2@example.com'),
          NamedAddress(name: 'Name Three', address: 'user3@example.com'),
        ]),
      );
    });

    test('Parses even invalid-looking emails without filtering', () {
      const input = 'user@example.com, , ; not-an-email, "Bad" <not-email>';
      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: '', address: 'user@example.com'),
          NamedAddress(name: '', address: 'not-an-email'),
          NamedAddress(name: 'Bad', address: 'not-email'),
        ]),
      );
    });

    test('Extracts duplicated emails without filtering', () {
      const input =
          '"A" <user@example.com>, user@EXAMPLE.com, "B" <USER@example.com>';
      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: 'A', address: 'user@example.com'),
          NamedAddress(name: '', address: 'user@EXAMPLE.com'),
          NamedAddress(name: 'B', address: 'USER@example.com'),
        ]),
      );
    });

    test('Handles single email', () {
      const input = 'single@example.com';
      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: '', address: 'single@example.com'),
        ]),
      );
    });

    test('Handles input with newlines and spacing', () {
      const input = '''
        "John" <john@example.com>
        user2@example.com ;
        "Jane"   <jane@example.com>
      ''';
      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: 'John', address: 'john@example.com'),
          NamedAddress(name: '', address: 'user2@example.com'),
          NamedAddress(name: 'Jane', address: 'jane@example.com'),
        ]),
      );
    });

    test('Parses mixed plain and quoted named emails', () {
      const input =
          'john.doe@example.com, jane.smith@example.com, alex.wilson@example.com, "ng van a" <ttnn@gmail.com>';
      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: '', address: 'john.doe@example.com'),
          NamedAddress(name: '', address: 'jane.smith@example.com'),
          NamedAddress(name: '', address: 'alex.wilson@example.com'),
          NamedAddress(name: 'ng van a', address: 'ttnn@gmail.com'),
        ]),
      );
    });

    test('Parses multiple quoted named emails without delimiters', () {
      const input =
          '"ng van a" <ttnn@gmail.com> "ng van b" <ttnn1@gmail.com> "ng van c" <ttnn2@gmail.com> "ng van d" <ttnn3@gmail.com>';
      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: 'ng van a', address: 'ttnn@gmail.com'),
          NamedAddress(name: 'ng van b', address: 'ttnn1@gmail.com'),
          NamedAddress(name: 'ng van c', address: 'ttnn2@gmail.com'),
          NamedAddress(name: 'ng van d', address: 'ttnn3@gmail.com'),
        ]),
      );
    });

    test('Handles semicolon after an email', () {
      const input =
          'john.doe@example.com;, jane.smith@example.com, alex.wilson@example.com';
      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: '', address: 'john.doe@example.com'),
          NamedAddress(name: '', address: 'jane.smith@example.com'),
          NamedAddress(name: '', address: 'alex.wilson@example.com'),
        ]),
      );
    });

    test('Handles completely empty string', () {
      const input = '';
      final result = StringConvert.extractNamedAddresses(input);
      expect(result, isEmpty);
    });

    test('Handles only spaces and separators', () {
      const inputs = [
        '   ',
        ',',
        ';',
        ',, ;;   ',
        ' , ; ',
        '   , ;  \n',
        '\n',
      ];

      for (final input in inputs) {
        final result = StringConvert.extractNamedAddresses(input);
        expect(result, isEmpty, reason: 'Failed on input: "$input"');
      }
    });

    test('Handles multiple delimiters between addresses', () {
      const input = 'user1@example.com,,;  user2@example.com;;  user3@example.com';
      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: '', address: 'user1@example.com'),
          NamedAddress(name: '', address: 'user2@example.com'),
          NamedAddress(name: '', address: 'user3@example.com'),
        ]),
      );
    });

    test('Handles multiple delimiters and spaces', () {
      const input =
          'user1@example.com   ,   user2@example.com ;   user3@example.com';
      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: '', address: 'user1@example.com'),
          NamedAddress(name: '', address: 'user2@example.com'),
          NamedAddress(name: '', address: 'user3@example.com'),
        ]),
      );
    });

    test('Handles a large number of addresses', () {
      const base = 'user';
      const domain = '@example.com';
      final buffer = StringBuffer();

      for (var i = 0; i < 1000; i++) {
        buffer.write('$base$i$domain');
        if (i != 999) buffer.write(', ');
      }

      final input = buffer.toString();
      final result = StringConvert.extractNamedAddresses(input);

      expect(result.length, equals(1000));
      expect(result.first, equals(NamedAddress(name: '', address: 'user0@example.com')));
      expect(result.last, equals(NamedAddress(name: '', address: 'user999@example.com')));
    });

    test('Handles mixed valid, invalid, and named addresses correctly', () {
      const input = '''
        user@example.com, , ; not-an-email,
        "Bad" <not-email>  "Bad-2" <not-email-2>,
        'Bad-3' <not-email-3>;
        'useb' <userb@example.com>
      ''';

      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: '', address: 'user@example.com'),
          NamedAddress(name: '', address: 'not-an-email'),
          NamedAddress(name: 'Bad', address: 'not-email'),
          NamedAddress(name: 'Bad-2', address: 'not-email-2'),
          NamedAddress(name: 'Bad-3', address: 'not-email-3'),
          NamedAddress(name: 'useb', address: 'userb@example.com'),
        ]),
      );
    });

    test('Handles subaddressing with + and subfolders', () {
      const input = '''
        john.doe@example.com;
        <userA+foldeA@example.com>;
        <userA+folder Hello@exmaple.com>;
        <userA+folderA.subFolderA@exmaple.com>;
        <user+folder Hello.subFolder Hello@exmaple.com>;
        alex.wilson@example.com
      ''';

      final result = StringConvert.extractNamedAddresses(input);

      expect(
        result,
        equals([
          NamedAddress(name: '', address: 'john.doe@example.com'),
          NamedAddress(name: '', address: 'userA+foldeA@example.com'),
          NamedAddress(name: '', address: 'userA+folder Hello@exmaple.com'),
          NamedAddress(name: '', address: 'userA+folderA.subFolderA@exmaple.com'),
          NamedAddress(name: '', address: 'user+folder Hello.subFolder Hello@exmaple.com'),
          NamedAddress(name: '', address: 'alex.wilson@example.com'),
        ]),
      );
    });
  });
}
