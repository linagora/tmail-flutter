import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/utils/localized_file_size_formatter.dart';

void main() {
  const oneGigabyte = 1024 * 1024 * 1024;

  group('LocalizedFileSizeFormatter::format', () {
    test('should use English units and decimal point for English locale', () {
      expect(LocalizedFileSizeFormatter.format(0, locale: 'en'), '0 B');
      expect(LocalizedFileSizeFormatter.format(3932, locale: 'en'), '3.84 KB');
      expect(LocalizedFileSizeFormatter.format(452 * oneGigabyte, locale: 'en'), '452 GB');
      expect(
        LocalizedFileSizeFormatter.format(452 * oneGigabyte - 3932, locale: 'en'),
        '452.00 GB',
      );
    });

    test('should use French units and decimal comma for French locale', () {
      expect(LocalizedFileSizeFormatter.format(0, locale: 'fr'), '0 o');
      expect(LocalizedFileSizeFormatter.format(3932, locale: 'fr'), '3,84 Ko');
      expect(LocalizedFileSizeFormatter.format(452 * oneGigabyte, locale: 'fr'), '452 Go');
      expect(
        LocalizedFileSizeFormatter.format(452 * oneGigabyte - 3932, locale: 'fr_FR'),
        '452,00 Go',
      );
    });

    test('should fall back to English for unknown locale', () {
      expect(LocalizedFileSizeFormatter.format(3932, locale: 'xx'), '3.84 KB');
    });
  });
}
