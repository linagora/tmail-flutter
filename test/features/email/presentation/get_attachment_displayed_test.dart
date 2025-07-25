import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

void main() {
  List<Attachment> generateAttachments(int count) =>
      List.generate(count, (i) => Attachment(name: 'A$i'));

  group('EmailUtils::getAttachmentDisplayed::', () {
    test('Should returns empty list when attachments list is empty', () {
      expect(
          EmailUtils.getAttachmentDisplayed(
            maxWidth: 1000,
            attachments: [],
            isMobile: true,
          ),
          []);
    });

    group('on mobile devices', () {
      test('Should returns all attachments when there are 3 or fewer', () {
        final attachments = generateAttachments(2);
        final result = EmailUtils.getAttachmentDisplayed(
          maxWidth: 1000,
          attachments: attachments,
          isMobile: true,
        );
        expect(result, attachments);
      });

      test('Should returns first 3 attachments when more than 3 exist', () {
        final attachments = generateAttachments(5);
        final result = EmailUtils.getAttachmentDisplayed(
          maxWidth: 1000,
          attachments: attachments,
          isMobile: true,
        );
        expect(result, attachments.sublist(0, 3));
      });
    });

    group('on non-mobile (desktop/web)', () {
      test('Should returns all attachments if maxWidth can fit all items', () {
        final attachments = generateAttachments(2);
        final result = EmailUtils.getAttachmentDisplayed(
          maxWidth: 700,
          attachments: attachments,
          isMobile: false,
        );
        expect(result, attachments);
      });

      test('Should returns only the number of items that fit in maxWidth', () {
        final attachments = generateAttachments(5);
        final result = EmailUtils.getAttachmentDisplayed(
          maxWidth: 900,
          attachments: attachments,
          isMobile: false,
        );
        expect(result, attachments.sublist(0, 3));
      });

      test(
          'Should returns only the first attachment if maxWidth is too small for any',
          () {
        final attachments = generateAttachments(3);
        final result = EmailUtils.getAttachmentDisplayed(
          maxWidth: 100,
          attachments: attachments,
          isMobile: false,
        );
        expect(result, [attachments.first]);
      });

      test(
          'Should clamps the number of displayed attachments to the list length',
          () {
        final attachments = generateAttachments(2);
        final result = EmailUtils.getAttachmentDisplayed(
          maxWidth: 2000,
          attachments: attachments,
          isMobile: false,
        );
        expect(result, attachments);
      });
    });
  });
}
