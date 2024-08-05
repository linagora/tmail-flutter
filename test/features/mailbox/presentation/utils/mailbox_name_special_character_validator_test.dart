import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/extensions/mailbox_name_special_character_validator_extension.dart';

void main() {
  group('isValid::test', () {

    test('should return true for a valid string', () {
      expect('hello'.isValid, isTrue);
    });

    test('should return false for a string starting with #', () {
      expect('#hello'.isValid, isFalse);
    });

    test('should return false for a string containing %', () {
      expect('hello%world'.isValid, isFalse);
    });

    test('should return false for a string containing *', () {
      expect('hello*world'.isValid, isFalse);
    });

    test('should return false for a string containing \\n', () {
      expect('hello\nworld'.isValid, isFalse);
    });

    test('should return false for a string containing \\r', () {
      expect('hello\rworld'.isValid, isFalse);
    });

    test('should return true for an empty string', () {
      expect(''.isValid, isTrue);
    });

    test('should return true for a string with no forbidden characters and not starting with #', () {
      expect('validString123'.isValid, isTrue);
    });
  });
}