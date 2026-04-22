import 'package:core/utils/logging/formatters/web_console_formatter.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = WebConsoleFormatter();

  const ansiReset = '\x1B[0m';
  const ansiRed = '\x1B[31m';
  const ansiYellow = '\x1B[33m';
  const ansiGreen = '\x1B[32m';
  const ansiBlue = '\x1B[34m';
  const ansiBold = '\x1B[1m';

  group('WebConsoleFormatter.format', () {
    test('critical wraps with red+bold and CRITICAL prefix', () {
      final result = formatter.format(Level.critical, 'msg');
      expect(result, '$ansiRed$ansiBold!!!CRITICAL!!! msg$ansiReset');
    });

    test('error wraps with red ANSI', () {
      final result = formatter.format(Level.error, 'msg');
      expect(result, '${ansiRed}msg$ansiReset');
    });

    test('warning wraps with yellow ANSI', () {
      final result = formatter.format(Level.warning, 'msg');
      expect(result, '${ansiYellow}msg$ansiReset');
    });

    test('info wraps with green ANSI', () {
      final result = formatter.format(Level.info, 'msg');
      expect(result, '${ansiGreen}msg$ansiReset');
    });

    test('debug wraps with blue ANSI', () {
      final result = formatter.format(Level.debug, 'msg');
      expect(result, '${ansiBlue}msg$ansiReset');
    });

    test('trace returns raw message without ANSI codes', () {
      final result = formatter.format(Level.trace, 'msg');
      expect(result, 'msg');
    });

    test('preserves raw message content', () {
      const raw = 'some detailed message';
      expect(formatter.format(Level.info, raw), contains(raw));
    });
  });
}
