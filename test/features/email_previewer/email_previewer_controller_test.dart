import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email_previewer/email_previewer_controller.dart';

void main() {
  group('EmailPreviewerController.opensWithNoOpener', () {
    test('cuts the opener for a web link', () {
      expect(
        EmailPreviewerController.opensWithNoOpener(
          Uri.parse('https://example.com'),
          isEmlPreview: false,
        ),
        isTrue,
      );
    });

    test('keeps the opener for the EML preview route', () {
      expect(
        EmailPreviewerController.opensWithNoOpener(
          Uri.parse('https://mail.example.com/previewer?id=1'),
          isEmlPreview: true,
        ),
        isFalse,
      );
    });

    test('keeps the opener for a mailto link', () {
      expect(
        EmailPreviewerController.opensWithNoOpener(
          Uri.parse('mailto:bob@example.com'),
          isEmlPreview: false,
        ),
        isFalse,
      );
    });
  });
}
