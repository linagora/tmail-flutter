import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/labels/presentation/utils/label_utils.dart';

void main() {
  group('LabelUtils.truncateLabel', () {
    test('returns original string when length <= maxLength', () {
      const name = 'ShortLabel';
      final result = LabelUtils.truncateLabel(name, maxLength: 16);
      expect(result, name);
    });

    test('truncates string when length > maxLength', () {
      const name = 'ThisIsAVeryLongLabel';
      final result = LabelUtils.truncateLabel(name, maxLength: 16);
      expect(result, 'ThisIsAVeryLong...');
    });

    test('works correctly with exact maxLength boundary', () {
      const name = '1234567890123456';
      final result = LabelUtils.truncateLabel(name, maxLength: 16);
      expect(result, name);
    });

    test('uses custom maxLength', () {
      const name = 'ABCDEFGH';
      final result = LabelUtils.truncateLabel(name, maxLength: 5);
      expect(result, 'ABCD...');
    });

    test('handles empty string gracefully', () {
      const name = '';
      final result = LabelUtils.truncateLabel(name, maxLength: 16);
      expect(result, '');
    });

    test('handles maxLength = 1 (still truncates safely)', () {
      const name = 'LongName';
      final result = LabelUtils.truncateLabel(name, maxLength: 1);
      expect(result, '...');
    });
  });
}
