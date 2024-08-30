import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/mixin/date_range_picker_mixin.dart';

class DateRangePickerMixinTest with DateRangePickerMixin {}

void main() {
  final dateRangePickerMixinTest = DateRangePickerMixinTest();

  group('DateRangePickerMixin::validateDateRange::', () {
    test('should set startDate to midnight and endDate to 23:59', () {
      // Arrange
      final DateTime startDate = DateTime(2024, 8, 30, 12, 30);
      final DateTime endDate = DateTime(2024, 8, 31, 15, 45);

      // Act
      final result = dateRangePickerMixinTest.validateDateRange(startDate: startDate, endDate: endDate);

      // Assert
      expect(result.startDate, DateTime(2024, 8, 30, 0, 0));
      expect(result.endDate, DateTime(2024, 8, 31, 23, 59));
    });

    test('should return null startDate and endDate if null input', () {
      // Act
      final result = dateRangePickerMixinTest.validateDateRange(startDate: null, endDate: null);

      // Assert
      expect(result.startDate, isNull);
      expect(result.endDate, isNull);
    });

    test('should set startDate to midnight and keep endDate null if only startDate is provided', () {
      // Arrange
      final DateTime startDate = DateTime(2024, 8, 30, 12, 30);

      // Act
      final result = dateRangePickerMixinTest.validateDateRange(startDate: startDate, endDate: null);

      // Assert
      expect(result.startDate, DateTime(2024, 8, 30, 0, 0));
      expect(result.endDate, isNull);
    });

    test('should set endDate to 23:59 and keep startDate null if only endDate is provided', () {
      // Arrange
      final DateTime endDate = DateTime(2024, 8, 31, 15, 45);

      // Act
      final result = dateRangePickerMixinTest.validateDateRange(startDate: null, endDate: endDate);

      // Assert
      expect(result.startDate, isNull);
      expect(result.endDate, DateTime(2024, 8, 31, 23, 59));
    });
  });
}