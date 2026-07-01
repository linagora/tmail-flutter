import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/twp_warning/twp_warning.dart';
import 'package:model/email/twp_warning/twp_warning_level.dart';

void main() {
  group('TwpWarning.parse', () {
    test('parses level, code and fallback text', () {
      final warning = TwpWarning.parse(
        'level:warn code:virus This email contains a virus',
        0,
      );
      expect(warning.level, TwpWarningLevel.warn);
      expect(warning.code, 'virus');
      expect(warning.fallbackText, 'This email contains a virus');
      expect(warning.index, 0);
    });

    test('accepts the level and code tokens in any leading order', () {
      final warning = TwpWarning.parse('code:virus level:error Boom', 2);
      expect(warning.level, TwpWarningLevel.error);
      expect(warning.code, 'virus');
      expect(warning.fallbackText, 'Boom');
      expect(warning.index, 2);
    });

    test('treats a plain message as info with no code', () {
      final warning = TwpWarning.parse('A plain warning message', 0);
      expect(warning.level, TwpWarningLevel.info);
      expect(warning.code, isNull);
      expect(warning.fallbackText, 'A plain warning message');
    });

    test('stops token parsing at the first non-token word', () {
      // `level:warn` after free text is body, not a leading token.
      final warning = TwpWarning.parse('Hello level:warn', 0);
      expect(warning.level, TwpWarningLevel.info);
      expect(warning.code, isNull);
      expect(warning.fallbackText, 'Hello level:warn');
    });

    test('defaults to info for an unknown level value', () {
      final warning = TwpWarning.parse('level:critical code:virus Text', 0);
      expect(warning.level, TwpWarningLevel.info);
      expect(warning.code, 'virus');
    });

    test('treats an empty code token as no code', () {
      final warning = TwpWarning.parse('level:warn code: Text', 0);
      expect(warning.code, isNull);
      expect(warning.fallbackText, 'Text');
    });

    test('collapses surrounding and repeated whitespace', () {
      final warning = TwpWarning.parse(
        '  level:warn   code:virus   A   B  ',
        0,
      );
      expect(warning.level, TwpWarningLevel.warn);
      expect(warning.code, 'virus');
      expect(warning.fallbackText, 'A B');
    });

    test('value equality on level, code, fallbackText and index', () {
      final a = TwpWarning.parse('level:warn code:virus Text', 1);
      final b = TwpWarning.parse('level:warn code:virus Text', 1);
      final c = TwpWarning.parse('level:warn code:virus Text', 2);
      expect(a, b);
      expect(a, isNot(c));
    });
  });

  group('TwpWarningLevel.fromValue', () {
    test('maps known values', () {
      expect(TwpWarningLevel.fromValue('warn'), TwpWarningLevel.warn);
      expect(TwpWarningLevel.fromValue('error'), TwpWarningLevel.error);
      expect(TwpWarningLevel.fromValue('info'), TwpWarningLevel.info);
    });

    test('is case-insensitive and trims whitespace', () {
      expect(TwpWarningLevel.fromValue('WARN'), TwpWarningLevel.warn);
      expect(TwpWarningLevel.fromValue('  Error '), TwpWarningLevel.error);
    });

    test('defaults to info for null, empty or unknown values', () {
      expect(TwpWarningLevel.fromValue(null), TwpWarningLevel.info);
      expect(TwpWarningLevel.fromValue(''), TwpWarningLevel.info);
      expect(TwpWarningLevel.fromValue('whatever'), TwpWarningLevel.info);
    });
  });
}
