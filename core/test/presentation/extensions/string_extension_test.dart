import 'package:core/presentation/extensions/string_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("firstLetterToUpperCase()", () {
    test("from 2 digits number", () {
      const twentyThree = '23';
      expect(twentyThree.firstLetterToUpperCase, equals('23'));
    });

    test("from 3 digits number", () {
      const twentyThreeThree = '233';
      expect(twentyThreeThree.firstLetterToUpperCase, equals('23'));
    });

    test("from 1 digit number", () {
      const two = '2';
      expect(two.firstLetterToUpperCase, equals('2'));
    });

    test("from 1 character", () {
      const two = 'A';
      expect(two.firstLetterToUpperCase, equals('A'));
    });

    test("from name with multiple words", () {
      const name = 'Grant big';
      expect(name.firstLetterToUpperCase, equals('GB'));
    });

    test("from name with one word", () {
      const name = 'Grant';
      expect(name.firstLetterToUpperCase, equals('GR'));
    });

    test("from name mix with number and word", () {
      const name = '23 Grant';
      expect(name.firstLetterToUpperCase, equals('GG'));
    });

    test("from name mix with word and number", () {
      const name = 'Grant 23';
      expect(name.firstLetterToUpperCase, equals('GG'));
    });

    test("from empty string", () {
      const name = '';
      expect(name.firstLetterToUpperCase, equals(''));
    });

    test("from special string", () {
      const name = '&^%';
      expect(name.firstLetterToUpperCase, equals('&^'));
    });

    test("from multiple special string", () {
      const name = '&^% *()^';
      expect(name.firstLetterToUpperCase, equals(''));
    });
  });

  group('fileExtension', () {
    test('should return empty string when no dot in path', () {
      expect('filename'.fileExtension, equals(''));
    });

    test('should return empty string when dot is last character', () {
      expect('filename.'.fileExtension, equals(''));
    });

    test('should return extension for simple filename', () {
      expect('filename.txt'.fileExtension, equals('txt'));
    });

    test('should return extension for filename with multiple dots', () {
      expect('file.name.with.dots.pdf'.fileExtension, equals('pdf'));
    });

    test('should return extension for path with directories', () {
      expect('/path/to/file/image.png'.fileExtension, equals('png'));
    });

    test('should handle empty string', () {
      expect(''.fileExtension, equals(''));
    });

    test('should handle whitespace after dot', () {
      expect('filename. txt'.fileExtension, equals(' txt'));
    });

    test('should handle complex extensions', () {
      expect('archive.tar.gz'.fileExtension, equals('gz'));
    });
  });

  group("sanitizedBidiForDisplay", () {
    test("removes a right-to-left override so the extension can't be visually reordered", () {
      const name = 'invoice\u202Efdp.exe';
      expect(name.sanitizedBidiForDisplay, equals('invoicefdp.exe'));
    });

    test("keeps normal punctuation in the file name", () {
      const name = 'invoice (final) v2.pdf';
      expect(name.sanitizedBidiForDisplay, equals(name));
    });

    String codePoint(int value) =>
        'U+${value.toRadixString(16).toUpperCase().padLeft(4, '0')}';

    for (final value in [
      0x0000, 0x001F, 0x007F, 0x0085, 0x009F, 0x061C, 0x200E,
      0x200F, 0x2028, 0x2029, 0x202A, 0x202E, 0x2066, 0x2069,
    ]) {
      test("strips ${codePoint(value)}", () {
        final char = String.fromCharCode(value);
        expect('a${char}b'.sanitizedBidiForDisplay, equals('ab'));
      });
    }

    for (final value in [
      0x0020, 0x007E, 0x00A0, 0x061B, 0x061D, 0x200C, 0x200D,
      0x2010, 0x2027, 0x202F, 0x2065, 0x206A,
    ]) {
      test("keeps ${codePoint(value)}", () {
        final name = 'a${String.fromCharCode(value)}b';
        expect(name.sanitizedBidiForDisplay, equals(name));
      });
    }

    for (final name in [
      '',
      'tài liệu.pdf',
      'تقرير.pdf',
      'דוח.pdf',
      String.fromCharCodes([0x1F468, 0x200D, 0x1F469, 0x200D, 0x1F467]),
    ]) {
      test("keeps ${name.runes} unchanged", () {
        expect(name.sanitizedBidiForDisplay, equals(name));
      });
    }

    test("strips several characters in different positions", () {
      final name = String.fromCharCodes(
        [0x202E, ...'inv'.codeUnits, 0x0007, ...'oice'.codeUnits, 0x2028, ...'.pdf'.codeUnits, 0x2066],
      );
      expect(name.sanitizedBidiForDisplay, equals('invoice.pdf'));
    });
  });
}