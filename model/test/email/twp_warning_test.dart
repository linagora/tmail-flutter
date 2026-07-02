import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/twp_warning.dart';

void main() {
  group('TwpWarning.parse:', () {
    test('parses a well-formed header line', () {
      final warning = TwpWarning.parse(
        'level:info code:suspicious-sender This email is from an external sender.',
        0,
      );

      expect(warning.level, TwpWarningLevel.info);
      expect(warning.code, 'suspicious-sender');
      expect(warning.fallbackText, 'This email is from an external sender.');
      expect(warning.index, 0);
    });

    test('defaults unknown level to info', () {
      final warning = TwpWarning.parse(
        'level:critical code:virus-detected Malware found.',
        0,
      );

      expect(warning.level, TwpWarningLevel.info);
      expect(warning.code, 'virus-detected');
    });

    test('parses warn and error levels', () {
      expect(TwpWarning.parse('level:warn code:x text', 0).level, TwpWarningLevel.warn);
      expect(TwpWarning.parse('level:error code:x text', 0).level, TwpWarningLevel.error);
    });

    test('defaults code to "unknown" when code prefix missing', () {
      final warning = TwpWarning.parse('level:warn just some text', 0);

      expect(warning.code, TwpWarning.defaultCode);
      expect(warning.fallbackText, 'just some text');
    });

    test('defaults both level and code when neither prefix present', () {
      final warning = TwpWarning.parse('a plain unstructured message', 0);

      expect(warning.level, TwpWarningLevel.info);
      expect(warning.code, TwpWarning.defaultCode);
      expect(warning.fallbackText, 'a plain unstructured message');
    });

    test('handles empty string without crashing', () {
      final warning = TwpWarning.parse('', 0);

      expect(warning.level, TwpWarningLevel.info);
      expect(warning.code, TwpWarning.defaultCode);
      expect(warning.fallbackText, '');
    });

    test('handles level with no trailing text', () {
      final warning = TwpWarning.parse('level:warn', 0);

      expect(warning.level, TwpWarningLevel.warn);
      expect(warning.code, TwpWarning.defaultCode);
      expect(warning.fallbackText, '');
    });

    test('handles code with no trailing text', () {
      final warning = TwpWarning.parse('level:warn code:no-text', 0);

      expect(warning.code, 'no-text');
      expect(warning.fallbackText, '');
    });

    test('preserves index passed in', () {
      expect(TwpWarning.parse('level:info code:x text', 3).index, 3);
    });
  });

  group('deduplicateTwpWarnings:', () {
    test('drops exact (level, code, fallbackText) duplicates, keeps first occurrence order', () {
      final input = [
        TwpWarning.parse('level:info code:a first', 0),
        TwpWarning.parse('level:info code:b second', 1),
        TwpWarning.parse('level:info code:a first', 2),
      ];

      final result = deduplicateTwpWarnings(input);

      expect(result.length, 2);
      expect(result[0].code, 'a');
      expect(result[1].code, 'b');
    });

    test('keeps partially-different entries (same code, different text)', () {
      final input = [
        TwpWarning.parse('level:info code:a first text', 0),
        TwpWarning.parse('level:info code:a second text', 1),
      ];

      final result = deduplicateTwpWarnings(input);

      expect(result.length, 2);
    });

    test('re-assigns contiguous 0-based indices over the deduplicated list', () {
      final input = [
        TwpWarning.parse('level:info code:a first', 0),
        TwpWarning.parse('level:info code:a first', 1),
        TwpWarning.parse('level:info code:b second', 2),
      ];

      final result = deduplicateTwpWarnings(input);

      expect(result[0].index, 0);
      expect(result[1].index, 1);
    });

    test('returns empty list for empty input', () {
      expect(deduplicateTwpWarnings([]), isEmpty);
    });
  });
}
