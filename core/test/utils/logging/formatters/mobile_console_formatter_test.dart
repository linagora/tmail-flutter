import 'package:core/utils/logging/formatters/mobile_console_formatter.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = MobileConsoleFormatter();

  group('MobileConsoleFormatter.format', () {
    test('critical has fire emoji prefix', () {
      expect(formatter.format(Level.critical, 'msg'), '🔥 CRITICAL: msg');
    });

    test('error has cross emoji prefix', () {
      expect(formatter.format(Level.error, 'msg'), '❌ ERROR: msg');
    });

    test('warning has warning emoji prefix', () {
      expect(formatter.format(Level.warning, 'msg'), '⚠️ WARNING: msg');
    });

    test('info has info emoji prefix', () {
      expect(formatter.format(Level.info, 'msg'), 'ℹ️ INFO: msg');
    });

    test('debug has bug emoji prefix', () {
      expect(formatter.format(Level.debug, 'msg'), '🐛 DEBUG: msg');
    });

    test('trace has magnifier emoji prefix', () {
      expect(formatter.format(Level.trace, 'msg'), '🔍 VERBOSE: msg');
    });

    test('preserves raw message content', () {
      const raw = 'some detailed message';
      expect(formatter.format(Level.info, raw), contains(raw));
    });
  });
}
