import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('DateTimeExtension → toPatternForEmailView', () {
    test('should return pattern without year when date is in current year', () {
      // Arrange
      final now = DateTime.now();
      final date = DateTime(now.year, 5, 10, 17, 30);

      // Act
      final pattern = date.toPatternForEmailView();
      final formatted = DateFormat(pattern, 'en_US').format(date);

      // Assert
      expect(pattern, 'dd MMM, hh:mm a');
      expect(
        formatted.contains('${date.year}'),
        isFalse,
        reason: 'Should not include year when in the current year',
      );
    });

    test('should return pattern with year when date is not in current year',
        () {
      // Arrange
      final now = DateTime.now();
      final date = DateTime(now.year - 1, 12, 25, 8, 45);

      // Act
      final pattern = date.toPatternForEmailView();
      final formatted = DateFormat(pattern, 'en_US').format(date);

      // Assert
      expect(pattern, 'dd MMM yyyy, hh:mm a');
      expect(
        formatted.contains('${date.year}'),
        isTrue,
        reason: 'Should include year when not in current year',
      );
    });

    test('should return pattern with year when date is null', () {
      // Arrange
      DateTime? date;

      // Act & Assert
      expect(
        date.toPatternForEmailView(),
        'dd MMM yyyy, hh:mm a',
        reason: 'Null date should return default pattern with year',
      );
    });

    test('should correctly display 12-hour format with AM/PM (no 24h time)',
        () {
      // Arrange
      final now = DateTime.now();
      final date = DateTime(now.year, 11, 13, 17, 0); // 17:00 = 5:00 PM

      // Act
      final pattern = date.toPatternForEmailView();
      final formatted = DateFormat(pattern, 'en_US').format(date);

      // Assert
      expect(pattern, 'dd MMM, hh:mm a');
      expect(
        formatted.contains('17:'),
        isFalse,
        reason: 'Should not show 24-hour format like 17:00',
      );
      expect(
        formatted.toLowerCase().contains('pm'),
        isTrue,
        reason: 'Should contain AM/PM indicator',
      );
      expect(
        formatted.contains('05:'),
        isTrue,
        reason: 'Should display 12-hour format (05:00 PM)',
      );
    });
  });
}
