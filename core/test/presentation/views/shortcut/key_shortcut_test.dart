import 'package:core/presentation/views/shortcut/key_shortcut.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KeyShortcut::matches', () {
    test('SHOULD match plain key WHEN no modifier is pressed', () {
      final shortcut = KeyShortcut(key: 'f', code: 'KeyF');

      expect(shortcut.matches('f'), isTrue);
    });

    test('SHOULD not match plain key WHEN ctrl modifier is pressed', () {
      final shortcut = KeyShortcut(key: 'f', code: 'KeyF', ctrl: true);

      expect(shortcut.matches('f'), isFalse);
      expect(shortcut.matches('f', ctrl: true), isTrue);
    });

    test('SHOULD not match plain key WHEN meta modifier is pressed', () {
      final shortcut = KeyShortcut(key: 'f', code: 'KeyF', meta: true);

      expect(shortcut.matches('f'), isFalse);
      expect(shortcut.matches('f', meta: true), isTrue);
    });

    test('SHOULD preserve shift matching behavior', () {
      final shortcut = KeyShortcut(key: 'r', code: 'KeyR', shift: true);

      expect(shortcut.matches('r'), isFalse);
      expect(shortcut.matches('r', shift: true), isTrue);
    });
  });
}
