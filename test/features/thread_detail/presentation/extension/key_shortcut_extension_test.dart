import 'package:core/presentation/views/shortcut/key_shortcut.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/shortcut/mail/mail_view_action_shortcut_type.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/key_shortcut_extension.dart';

void main() {
  group('KeyShortcutExtension::mailViewActionShortcutType', () {
    test('SHOULD return forward WHEN pressing f without modifiers', () {
      final shortcut = KeyShortcut(key: 'f', code: 'KeyF');

      expect(
        shortcut.mailViewActionShortcutType,
        MailViewActionShortcutType.forward,
      );
    });

    test('SHOULD return null WHEN pressing meta + f (browser search)', () {
      final shortcut = KeyShortcut(key: 'f', code: 'KeyF', meta: true);

      expect(shortcut.mailViewActionShortcutType, isNull);
    });

    test('SHOULD return null WHEN pressing ctrl + f (browser search)', () {
      final shortcut = KeyShortcut(key: 'f', code: 'KeyF', ctrl: true);

      expect(shortcut.mailViewActionShortcutType, isNull);
    });

    test('SHOULD return reply WHEN pressing r without modifiers', () {
      final shortcut = KeyShortcut(key: 'r', code: 'KeyR');

      expect(
        shortcut.mailViewActionShortcutType,
        MailViewActionShortcutType.reply,
      );
    });

    test('SHOULD return replyAll WHEN pressing shift + r', () {
      final shortcut = KeyShortcut(key: 'r', code: 'KeyR', shift: true);

      expect(
        shortcut.mailViewActionShortcutType,
        MailViewActionShortcutType.replyAll,
      );
    });

    test('SHOULD return null WHEN pressing meta + r', () {
      final shortcut = KeyShortcut(key: 'r', code: 'KeyR', meta: true);

      expect(shortcut.mailViewActionShortcutType, isNull);
    });
  });
}
