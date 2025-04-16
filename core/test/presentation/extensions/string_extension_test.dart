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
}